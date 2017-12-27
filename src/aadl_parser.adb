
with GNAT.OS_Lib, Text_IO;
use Text_IO;

with TASTE,
     TASTE.AADL_Parser,
     Templates_Parser;
use TASTE.AADL_Parser,
    Templates_Parser;

procedure AADL_Parser is
   Model : TASTE_Model;
   procedure Dump_With_Templates (Model : TASTE_Model) is
      Set : Translate_Set;
      Vec : Tag;
   begin
      Set_Tag_Separators (Start_With => "<",
                          Stop_With  => ">");
      Insert (Set,
              Assoc ("Interface_View",
                     Model.Configuration.Interface_View.all));
      Insert (Set,
              Assoc ("Deployment_View",
                     Model.Configuration.Deployment_View.all));
      Insert (Set, Assoc ("Data_View", Model.Configuration.Data_View.all));
      Insert (Set, Assoc ("Output_Dir", Model.Configuration.Output_Dir.all));
      for Each of Model.Configuration.Other_Files loop
         Vec := Vec & Each;
      end loop;
      Insert (Set, Assoc ("Other_Files", Vec));
      Insert (Set, Assoc ("Skeletons",  Model.Configuration.Skeletons));
      Insert (Set, Assoc ("Glue",       Model.Configuration.Glue));
      Insert (Set, Assoc ("Use_POHIC",  Model.Configuration.Use_POHIC));
      Insert (Set, Assoc ("Debug_Flag", Model.Configuration.Debug_Flag));
      Insert (Set, Assoc ("Version",    Model.Configuration.Version));
      Insert (Set, Assoc ("Timer_Resolution",
                                        Model.Configuration.Timer_Resolution));
      Put_Line ("=== Template-generated debug output ===");
      Put_Line (Parse ("configuration.tmplt", Set));
   end Dump_With_Templates;
begin
   Model := Parse_Project;
   --  Model.Dump;
   Dump_With_Templates (Model);
exception
   when TASTE.Quit_TASTE =>
      GNAT.OS_Lib.OS_Exit (1);
end AADL_Parser;
