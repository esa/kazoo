with Text_IO; use Text_IO;
with Interfaces; use Interfaces;

package body Toto is
   --  Implement the body of the function here
   --  If you need global, per-instance  data, do not add it here, but
   --  edit the interface view and add them to the Context Parameters tab

   procedure Compute_Pi (Self : in out Context) is
   begin
      Put_Line ("Computing PI.....");
   end Compute_Pi;
   
   procedure Dosomething
      (Self : in out Context;
       A_In  : in out asn1SccT_Int32;
       B_In  : in out asn1SccT_Boolean;
       C_Out :    out asn1SccMy_Integer) is
   begin
      Put_Line ("Dosomething called : " & A_In'Img & " " & B_In'Img); 
      C_Out := 3;
   end Dosomething;
   
   procedure Pulse (Self : in out Context) is
      Timeout : asn1SccT_UInt32 := 2000;
   begin
      if Self.Namo = 0 then
          RI_Set_my_timer (Timeout);
          Self.Namo := 1;
      end if;

      Put_Line ("Pulse");
      RI_Walk;
   end Pulse;

   procedure My_Timer (Self : in out Context) is
      Tired : asn1SccT_Boolean := True;
   begin
      Put_Line ("*** Timer expired... *** ");
      Self.Namo := 0;
      RI_Run (Tired);
   end My_Timer;
   
begin
   Put_Line ("Generic Toto Startup");
end Toto;
