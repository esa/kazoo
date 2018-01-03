with Text_IO,
     Templates_Parser,
     TASTE.Templates;
use  Text_IO,
     Templates_Parser,
     TASTE.Templates;

package body TASTE.Backend.Build_Script is
   procedure Generate (Model : TASTE_Model) is
      Vec_Code : Tag;
      Vec_Zip  : Tag;
      Vec_Func : Tag;
   begin
      for Each of Model.Interface_View.Flat_Functions loop
         New_Set;
         Tmpl_Map ("Function_Name", Each.Name);
         Tmpl_Map ("Language", Each.Language'Img);
         declare
            Element_Code : constant String := TASTE.Templates.Generate
                                  (Model.Configuration.Binary_Path.all
                                   & "templates/build-script-gencode.tmplt");
            Element_Zip : constant String := TASTE.Templates.Generate
                                  (Model.Configuration.Binary_Path.all
                                   & "templates/build-script-zip.tmplt");
            Element_Func : constant String := TASTE.Templates.Generate
                                  (Model.Configuration.Binary_Path.all
                                   & "templates/build-script-func.tmplt");
         begin
            Vec_Code := Vec_Code & Element_Code;
            Vec_Zip  := Vec_Zip  & Element_Zip;
            Vec_Func := Vec_Func & Element_Func;
         end;
      end loop;
      Put_Line ("==== Generating build script ====");
      New_Set;
      Tmpl_Map ("Interface_View_Path", Model.Configuration.Interface_View.all);
      Tmpl_Map ("Output_Path",         Model.Configuration.Output_Dir.all);
      Tmpl_Map ("Generate_Code",       Vec_Code);
      Tmpl_Map ("Zip_Code",            Vec_Zip);
      Tmpl_Map ("Functions",           Vec_Func);
      Tmpl_Map ("CodeCoverage",        "# TODO");

      Put_Line (TASTE.Templates.Generate (Model.Configuration.Binary_Path.all
                                          & "templates/build-script.tmplt"));

   end Generate;
end TASTE.Backend.Build_Script;
