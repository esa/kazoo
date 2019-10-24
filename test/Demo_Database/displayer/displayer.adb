-- User implementation of the displayer function
-- This file will never be overwritten once edited and modified
-- Only the interface of functions is regenerated (in the .ads file)

--pragma Profile (Ravenscar);

pragma Style_Checks (off);
pragma Warnings (off);

with dataview; use dataview;

with adaasn1rtl; use adaasn1rtl;

with ada.Integer_Text_IO; use ada.Integer_Text_IO;

with ada.Long_Float_Text_IO; use ada.Long_Float_Text_IO;

with system.io; use system.io;

with Interfaces; use Interfaces;

with Ada.Interrupts, Ada.Interrupts.Names;

use Ada.Interrupts, Ada.Interrupts.Names;

package body displayer is
   type A_String is access String;
   Person        : asn1Scctm_t;
   S             : A_String;
   bTmHasArrived : Boolean;
   Number        : asn1SccHK_T_value_to_plot := 0;
   HK            : aliased asn1SccHK_T;

   --  Add a signal handler: use " pkill -usr1 mypartition " to trigger it
   --  it works with both pohic and pohiada
   package Sigusr1_Handler is
      protected Handler is
         procedure Handle;
         pragma Interrupt_Handler (Handle);
         pragma Attach_Handler (Handle, Sigusr1);
      end Handler;
   end Sigusr1_Handler;

   package body Sigusr1_Handler is
      protected body Handler is
         procedure Handle is
         begin
            System.IO.Put_Line ("Got interrupt!");
         end Handle;
      end Handler;
   end Sigusr1_Handler;

   procedure Displayer_Put_TC (TC : in out asn1SccTC_T) is
   begin
      case TC.Action.Kind is
         when Display_PRESENT =>
            for J in 1 .. TC.Action.Display.Length loop
               person.data (J) := TC.Action.Display.Data (J);
            end loop;
            Person.Length := TC.Action.Display.Length;
            if (person.length > 0) then
               bTmHasArrived := True;
            end if;
         when housekeeping_PRESENT =>
            HK :=
              (Exist       => (Value_To_Plot => 1), Value_To_Plot => Number,
               Destination => TC.Action.Housekeeping);
            HousekeepingTM (HK);
         when others =>
            null;
      end case;
   end Displayer_Put_TC;

   procedure cyclicdisplayer is
      My_TM : aliased asn1Scctm_t;
      I     : Integer;
   begin
      System.IO.Put_Line ("cyclicdisplayer");
      if bTmHasArrived then
         for i in 1 .. Person.Length loop
            My_TM.Data (i) := Person.Data (i);
         end loop;
         My_TM.Length := Person.Length;
         router_send_tm (My_TM);
      end if;
      Number := (Number + 1) mod 16535;
   end cyclicdisplayer;

begin
   system.io.put_line ("init of displayer done");
   person        := asn1SccTM_T_Init;
   bTmHasArrived := False;

end displayer;
