with Ada.Exceptions,
     GNAT.OS_Lib,
     TASTE,
     TASTE.AADL_Parser,
     TASTE.Parser_Utils,
     TASTE.Model_Transformations,
     TASTE.Dump;
use TASTE.AADL_Parser,
    TASTE.Parser_Utils,
    TASTE.Model_Transformations;

procedure Kazoo is
begin
   declare
      Model       : constant TASTE_Model := Parse_Project;
      Transformed :          TASTE_Model := Transform (Model);
   begin
      if Model.Configuration.Debug_Flag then
         TASTE.Dump.Dump_Input_Model (Model);
         Transformed.Dump;
      end if;

      if Transformed.Configuration.Glue then
         Transformed.Add_Concurrency_View;
         Transformed.Concurrency_View.Generate_CV;
      end if;

      Transformed.Generate_Build_Script;
      Transformed.Generate_Code;
   end;
exception
   when TASTE.Quit_TASTE =>
      GNAT.OS_Lib.OS_Exit (1);
   when Error : others =>
      Put_Error (Ada.Exceptions.Exception_Message (Error));
      GNAT.OS_Lib.OS_Exit (1);
end Kazoo;
