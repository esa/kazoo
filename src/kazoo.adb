with GNAT.OS_Lib,
     TASTE,
     TASTE.AADL_Parser,
     TASTE.Model_Transformations;
use TASTE.AADL_Parser,
    TASTE.Model_Transformations;

procedure Kazoo is
begin
   declare
      Model       : constant TASTE_Model := Parse_Project;
      Transformed : TASTE_Model := Transform (Model);
   begin
      if Transformed.Configuration.Glue then
         Transformed.Add_Concurrency_View;
         Transformed.Concurrency_View.Generate_CV;
      end if;
      Transformed.Dump;
      Transformed.Generate_Build_Script;
      Transformed.Generate_Code;
   end;
exception
   when TASTE.Quit_TASTE =>
      GNAT.OS_Lib.OS_Exit (1);
end Kazoo;