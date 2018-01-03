with GNAT.OS_Lib,
     TASTE,
     TASTE.AADL_Parser;
use TASTE.AADL_Parser;

procedure AADL_Parser is
   Model : TASTE_Model;
begin
   Model := Parse_Project;
   Model.Dump;
   Model.Generate_Build_Script;
exception
   when TASTE.Quit_TASTE =>
      GNAT.OS_Lib.OS_Exit (1);
end AADL_Parser;
