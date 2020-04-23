--  User implementation of the function2 function
--  This file will never be overwritten once edited and modified
--  Only the interface of functions is regenerated (in the .ads file)


--  Notes : in RM0090 section 10-3-3 we can find the mapping table for the DMA
--  it says for example that DMA1 can be connected to the transmitter of USART2
--  (USART2_Tx) using Channel 4 / Stream 6. This is the only right config
--  Main  mappings:
--  DMA1 : USART2_Tx / Channel 4 / Stream 6
--  DMA1 : USART2_Rx / Channel 5 / Stream 5
--  DMA2 : USART6_Tx / Channel 5 / Stream 6 or Stream 7
--  DMA2 : USART6_Rx / Chennel 5 / Stream 1 or Stream 2
--
--  Then the alternate functions map also to specific USARTs:
--  AF7 maps to USART 1..3
--  AF8 maps to USART 4..6
--
--  And in the Datasheet of STM32F405/7 we have the GPIO / AF mapping:
--  PC6 = USART6_Tx
--  PC7 = USART6_Rx
--  PA2 = USART2_Tx (AF7)
--  PA3 = USART2_Rx (AF7)


pragma Style_Checks (off);

with STM32.Board;            use STM32.Board;
with STM32.GPIO;             use STM32.GPIO;
with STM32.DMA;              use STM32.DMA;
with STM32.Device;           use STM32.Device;
with HAL;                    use HAL;
with STM32.USARTs;           use STM32.USARTs;
with Ada.Interrupts;         use Ada.Interrupts;
with Ada.Interrupts.Names;   use Ada.Interrupts.Names;
--  with Types;                  use Types;
with System;
with Interfaces;             use Interfaces;


package body function2 is

   Transceiver    : USART renames USART_2;
   Transceiver_AF : constant STM32.GPIO_Alternate_Function := GPIO_AF_USART2_7;

   TX_Pin         : constant GPIO_Point           := PA2;
   RX_Pin         : constant GPIO_Point           := PA3;

   Controller     : DMA_Controller                renames DMA_1;
   Tx_Channel     : constant DMA_Channel_Selector := Channel_4;
   Tx_Stream      : constant DMA_Stream_Selector  := Stream_6;

   Rx_Channel     : constant DMA_Channel_Selector := Channel_5;
   Rx_Stream      : constant DMA_Stream_Selector  := Stream_5;

   --  DMA_Tx_IRQ : constant Interrupt_ID := DMA1_Stream6_Interrupt;
   --  DMA_Rx_IRQ : constant Interrupt_ID := DMA1_Stream5_Interrupt;
   USART_IRQ      : constant Interrupt_ID := USART2_Interrupt;

   --  One-message buffer for reception
   Incoming_Msg   : aliased asn1sccDebug_PrintableString :=
                                       asn1sccDebug_PrintableString_Init;
   Msg_Idx        : Natural := 0;
   Msg_Complete   : Boolean := False;

   procedure Initialize_Hardware;
   procedure String_To_OctetString (str : String ;
                                    res : in out asn1sccDebug_PrintableString);

   procedure String_To_OctetString (str : String ;
                                    res : in out asn1sccDebug_PrintableString)
   is
      idx : Natural := 1;
   begin
      res.Length := str'Length;
      for char of str loop
         exit when idx > res.Data'Length;
         res.Data (idx) := Character'Pos (char);
         idx := idx + 1;
      end loop;
   end String_To_OctetString;

   protected Reception is
      -- Interrupt business must be done in a protected object

      pragma Interrupt_Priority;
      procedure Handle_Reception with Inline;
      procedure IRQ_Handler      with Attach_Handler => USART_IRQ;
   end Reception;

   protected body Reception is

       procedure Handle_Reception is
           --  Receive one char.
           Received_Char : constant Character :=
                                 Character'Val (Current_Input (Transceiver));
           --  Buf : aliased asn1sccDebug_PrintableString;
       begin
           if Received_Char /= ASCII.CR and Msg_Idx < Incoming_Msg.Data'Length
           then
              if Msg_Idx = 0 then
                  Incoming_Msg := asn1sccDebug_PrintableString_Init;
                  Msg_Complete := False;
              end if;
              --  Append character to buffer
              Msg_Idx := Msg_Idx + 1;
              Incoming_Msg.Data (Msg_Idx) := Character'Pos (Received_Char);
              Incoming_Msg.Length := Incoming_Msg.Length + 1;
           else
               --  Reception complete
               Msg_Idx := 0;
               loop
                   exit when not Status (Transceiver, Read_Data_Register_Not_Empty);
               end loop;
           -- If we disable interrupts here, it allows to receive data only
           -- when we want... at the risk of missing data.
           --  Disable_Interrupts (Transceiver, Source => Received_Data_Not_Empty);
           --  String_To_OctetString(str => "Received: " & Received_Char & ASCII.CR & ASCII.LF,
           --                      res => Buf);
              --  String_To_OctetString(str => "Received: ", res => Buf);
              --  Send_to_UART (Buf'Access);
              --  Send_to_UART (Incoming_Msg'Access);
              --  Incoming_Msg.Length := 0;
              Msg_Complete        := True;
           end if;
       end;

       procedure IRQ_Handler is
       begin
          --  check for data arrival
          if Status (Transceiver, Read_Data_Register_Not_Empty) and
           Interrupt_Enabled (Transceiver, Received_Data_Not_Empty)
         then
            Handle_Reception;
            Clear_Status (Transceiver, Read_Data_Register_Not_Empty);
         end if;
       end IRQ_Handler;
    end Reception;

   -------------------------------
   -- Initialize_Hardware --
   -------------------------------

   procedure Initialize_Hardware is
      Config_GPIO : constant GPIO_Port_Configuration :=
         (Mode           => Mode_AF,
          AF             => Transceiver_AF,
          AF_Speed       => Speed_50MHz,
          AF_Output_Type => Push_Pull,
          Resistors      => Pull_Up);

      Config_DMA  : DMA_Stream_Configuration;
   begin

      ------------------------
      -- GPIO Configuration --
      ------------------------

      Enable_Clock (RX_Pin & TX_Pin);

      Configure_IO (RX_Pin & TX_Pin,
                    Config => Config_GPIO);

            -------------------------
      -- USART Configuration --
      -------------------------
      Enable_Clock     (Transceiver);
      Enable           (Transceiver);
      Set_Baud_Rate    (Transceiver, 115_200);
      Set_Mode         (Transceiver, Tx_Rx_Mode);
      Set_Stop_Bits    (Transceiver, Stopbits_1);
      Set_Word_Length  (Transceiver, Word_Length_8);
      Set_Parity       (Transceiver, No_Parity);
      Set_Flow_Control (Transceiver, No_Flow_Control);


      --------------------
      -- Initialize_DMA --
      --------------------

      Enable_Clock (Controller);
      Reset (Controller, Tx_Stream);

      Config_DMA.Channel                      := Tx_Channel;
      Config_DMA.Direction                    := Memory_To_Peripheral;
      Config_DMA.Increment_Peripheral_Address := False;
      Config_DMA.Increment_Memory_Address     := True;
      Config_DMA.Peripheral_Data_Format       := Bytes;
      Config_DMA.Memory_Data_Format           := Bytes;
      Config_DMA.Operation_Mode               := Normal_Mode;
      Config_DMA.Priority                     := Priority_Very_High;
      Config_DMA.FIFO_Enabled                 := True;
      Config_DMA.FIFO_Threshold               := FIFO_Threshold_Full_Configuration;
      Config_DMA.Memory_Burst_Size            := Memory_Burst_Single;
      Config_DMA.Peripheral_Burst_Size        := Peripheral_Burst_Single;
      Configure (Controller, Tx_Stream, Config_DMA);

      Enable    (Transceiver);
      Enable_Interrupts (Transceiver, Received_Data_Not_Empty);

   end Initialize_Hardware;

   --  ----------------------------------------------------  --
   --  Provided interface "Get_Message"
   --  ----------------------------------------------------  --
   procedure Get_Message(Last_Message: out asn1sccDebug_PrintableString) is
   begin
       Disable_Interrupts (Transceiver, Source => Received_Data_Not_Empty);
       if Msg_Complete then
           Last_Message := Incoming_Msg;
           Msg_Complete := False;
       else
           Last_Message.Length := 0;
       end if;
      Enable_Interrupts (Transceiver, Received_Data_Not_Empty);
   end Get_Message;

   ---------------------------------------------------------
   --  Provided interface "Send_to_UART"
   ---------------------------------------------------------
   procedure Send_to_UART(chars: in out asn1sccDebug_PrintableString) is
   begin
      -- Previous Send should have left status "Transfer Complete Indicated"
      -- We must clear it before starting a new transfer
      Clear_All_Status (Controller, Tx_Stream);
      Start_Transfer
        (Controller,
         Tx_Stream,
         Source      => chars.Data'Address,
         Destination => Data_Register_Address (Transceiver),
         Data_Count  => UInt16(chars.length));

      Enable_DMA_Transmit_Requests (Transceiver);
   end;

   procedure Switch_Leds_On is
   begin
       All_LEDs_On;
   end;

   procedure Switch_Leds_Off is
   begin
       All_LEDs_Off;
   end;

   begin
      STM32.Board.Initialize_LEDs;
      All_LEDs_Off;
      Turn_On (Green_LED);
      Initialize_Hardware;

end function2;
