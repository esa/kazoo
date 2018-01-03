with Text_IO,
     TASTE.Templates;
use  Text_IO,
     TASTE.Templates;

package body TASTE.Backend.Build_Script is
   procedure Generate (Model : TASTE_Model) is
   begin
      Put_Line ("==== Generating build script ====");
      New_Set;
      Tmpl_Map ("Interface_View_Path", Model.Configuration.Interface_View.all);
      Tmpl_Map ("Output_Path",         Model.Configuration.Output_Dir.all);
      Tmpl_Map ("Generate_Code",       "# TODO");
      Tmpl_Map ("Zip_Code",            "# TODO");
      Tmpl_Map ("Functions",           "# TODO \");
      Tmpl_Map ("CodeCoverage",        "# TODO");

      Put_Line (TASTE.Templates.Generate (Model.Configuration.Binary_Path.all
                                          & "templates/build-script.tmplt"));

   end Generate;
end TASTE.Backend.Build_Script;
