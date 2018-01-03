with Text_IO,
     Templates_Parser;
use  Text_IO,
     Templates_Parser;

package body TASTE.Backend.Build_Script is
   procedure Generate (Model : TASTE_Model) is
      Prefix : constant String := Model.Configuration.Binary_Path.all
                                  & "templates/";
      Vec_Code : Tag;
      Vec_Zip  : Tag;
      Vec_Func : Tag;
   begin
      for Each of Model.Interface_View.Flat_Functions loop
         declare
            Template_Data : constant Translate_Table :=
               (1 => Assoc ("Function_Name", Each.Name),
                2 => Assoc ("Language", Each.Language'Img));
            Element_Code : constant String :=
               Parse (Prefix & "build-script-gencode.tmplt", Template_Data);
            Element_Zip : constant String :=
               Parse (Prefix & "build-script-zip.tmplt", Template_Data);
            Element_Func : constant String :=
               Parse (Prefix & "build-script-func.tmplt", Template_Data);
         begin
            if Element_Code'Length > 0 then
               Vec_Code := Vec_Code & Element_Code;
            end if;
            if Element_Zip'Length > 0 then
               Vec_Zip  := Vec_Zip  & Element_Zip;
            end if;
            if Element_Func'Length > 0 then
               Vec_Func := Vec_Func & Element_Func;
            end if;
         end;
      end loop;
      Put_Line ("==== Generating build script ====");
      declare
         Template_Data : constant Translate_Table :=
            (1 => Assoc ("Interface_View_Path",
                         Model.Configuration.Interface_View.all),
             2 => Assoc ("Output_Path",   Model.Configuration.Output_Dir.all),
             3 => Assoc ("Generate_Code", Vec_Code),
             4 => Assoc ("Zip_Code",      Vec_Zip),
             5 => Assoc ("Functions",     Vec_Func),
             6 => Assoc ("CodeCoverage",  "# TODO"));
      begin
         Put_Line (Parse (Prefix & "build-script.tmplt", Template_Data));
      end;
   end Generate;
end TASTE.Backend.Build_Script;
