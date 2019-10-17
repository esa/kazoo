--  User implementation of the function2 function
--  This file will never be overwritten once edited and modified
--  Only the interface of functions is regenerated (in the .ads file)


pragma Style_Checks (off);

with STM32.Board;            use STM32.Board;
with STM32.GPIO;             use STM32.GPIO;
with STM32.Device;           use STM32.Device;
--  with Types;                  use Types;
with System;
with Interfaces;             use Interfaces;


package body function2 is


   procedure Pulse is
   begin
      Toggle_LEDs (All_LEDs);
   end;


   procedure Switch_Leds_On is
   begin
      All_LEDs_On;
   end;

   ---------------------------------------------------------
   --  Provided interface "Switch_Leds_Off"
   ---------------------------------------------------------
   procedure Switch_Leds_Off is
   begin
      All_LEDs_Off;
   end;

   begin
      STM32.Board.Initialize_LEDs;
      All_LEDs_Off;
      Turn_On (Green_LED);

end function2;
