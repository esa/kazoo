with GNAT.OS_Lib,
     TASTE,
     TASTE.AADL_Parser,
     TASTE.Model_Transformations;
use TASTE.AADL_Parser,
    TASTE.Model_Transformations;

procedure AADL_Parser is
   Model       : constant TASTE_Model := Parse_Project;
   dummy_Trans : constant TASTE_Model := Transform (Model);
begin
   Model.Dump;
   Model.Generate_Build_Script;
   Model.Generate_Skeletons;
exception
   when TASTE.Quit_TASTE =>
      GNAT.OS_Lib.OS_Exit (1);
end AADL_Parser;
