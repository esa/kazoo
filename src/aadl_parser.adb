
with GNAT.OS_Lib, Text_IO;
use Text_IO;

with TASTE,
     TASTE.AADL_Parser,
     TASTE.Templates;
use TASTE.AADL_Parser,
    TASTE.Templates;
with Templates_Parser;
use Templates_Parser;

procedure AADL_Parser is
   Model : TASTE_Model;
   procedure Dump_With_Templates (Model : TASTE_Model) is
      Vec : Tag;
   begin
      New_Set;

      Map ("Interface_View",  Model.Configuration.Interface_View.all);
      Map ("Deployment_View", Model.Configuration.Deployment_View.all);
      Map ("Data_View", Model.Configuration.Data_View.all);
      Map ("Output_Dir", Model.Configuration.Output_Dir.all);
      for Each of Model.Configuration.Other_Files loop
         Vec := Vec & Each;
      end loop;
      Map ("Other_Files",      Vec);
      Map ("Skeletons",        Model.Configuration.Skeletons);
      Map ("Glue",             Model.Configuration.Glue);
      Map ("Use_POHIC",        Model.Configuration.Use_POHIC);
      Map ("Debug_Flag",       Model.Configuration.Debug_Flag);
      Map ("Version",          Model.Configuration.Version);
      Map ("Timer_Resolution", Model.Configuration.Timer_Resolution);
      Put_Line ("=== Template-generated debug output ===");
      Put_Line (Generate ("configuration.tmplt"));
   end Dump_With_Templates;
begin
   Model := Parse_Project;
   --  Model.Dump;
   Dump_With_Templates (Model);
exception
   when TASTE.Quit_TASTE =>
      GNAT.OS_Lib.OS_Exit (1);
end AADL_Parser;
