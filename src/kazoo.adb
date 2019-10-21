with Ada.Exceptions,
     GNAT.OS_Lib,
     TASTE,
     TASTE.AADL_Parser,
     TASTE.Parser_Utils,
     TASTE.Dump;
use TASTE.AADL_Parser,
    TASTE.Parser_Utils;

procedure Kazoo is
begin
   declare
      Model : TASTE_Model := Parse_Project;
   begin
      if Model.Configuration.Debug_Flag then
         TASTE.Dump.Dump_Input_Model (Model);
         Model.Dump;
      end if;

      if Model.Configuration.Glue then
         Model.Preprocessing;
         Model.Add_Concurrency_View;
         Model.Concurrency_View.Generate_CV;
      end if;

      Model.Generate_Build_Script;
      Model.Generate_Code;
   end;
exception
   when TASTE.Quit_TASTE =>
      GNAT.OS_Lib.OS_Exit (1);
   when Error : others =>
      Put_Error (Ada.Exceptions.Exception_Message (Error));
      GNAT.OS_Lib.OS_Exit (1);
end Kazoo;
