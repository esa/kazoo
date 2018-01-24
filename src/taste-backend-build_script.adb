with System.OS_Lib,
     Text_IO,
     Ada.Exceptions,
     Ada.Directories,
     Templates_Parser,
     TASTE.Parser_Utils;
use  System.OS_Lib,
     Text_IO,
     Ada.Exceptions,
     Ada.Directories,
     Templates_Parser,
     TASTE.Parser_Utils;

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
                2 => Assoc ("Language", Language_Spelling (Each)));
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
      Put_Info ("Generating build script");
      declare
         Template_Data : constant Translate_Set :=
           +Assoc ("Interface_View_Path",
                   Model.Configuration.Interface_View.all)
           & Assoc ("Output_Path",   Model.Configuration.Output_Dir.all)
           & Assoc ("Generate_Code", Vec_Code)
           & Assoc ("Zip_Code",      Vec_Zip)
           & Assoc ("Functions",     Vec_Func)
           & Assoc ("CodeCoverage",  "# TODO");
         Result : constant String := Parse (Prefix & "build-script.tmplt",
                                            Template_Data);
         Output_Path : constant String := Model.Configuration.Output_Dir.all;
         Filename    : constant String := Output_Path & "/build-script.sh";
         Output      : File_Type;
         Success     : Boolean;
      begin
         Create_Path (Output_Path);
         if Exists (Filename) then
            Put_Info ("Making backup of build script (build-script.sh.old)");
            Rename_File (Old_Name => Filename,
                         New_Name => Output_Path & "/build-script.sh.old",
                         Success  => Success);
            if not Success then
               raise Backend_Error with "Impossible to rename build-script.sh";
            end if;
         end if;
         Create (File => Output, Mode => Out_File, Name => Filename);
         Put_Line (Output, Result);
         Close (Output);
      exception
         when E : others =>
            if Is_Open (Output) then
               Close (Output);
            end if;
            raise Backend_Error with "Generation of build script failed: "
              & Exception_Message (E);
      end;
   end Generate;
end TASTE.Backend.Build_Script;
