with Text_IO,
     Ada.Exceptions,
     Ada.Directories,
     Templates_Parser,
     TASTE.Parser_Utils;
use  Text_IO,
     Ada.Exceptions,
     Ada.Directories,
     Templates_Parser,
     TASTE.Parser_Utils;

package body TASTE.Backend.Build_Script is
   procedure Generate (Model : TASTE_Model) is
      Prefix : constant String :=
        Model.Configuration.Binary_Path.Element & "templates/";
   begin
      Put_Info ("Generating legacy build-script.sh");
      declare
         Template_Data : constant Translate_Set :=
           +Assoc ("Interface_View_Path",
                   Model.Configuration.Interface_View.Element)
           & Assoc ("Output_Path",   Model.Configuration.Output_Dir.Element);
         Result : constant String := Parse (Prefix & "build-script.tmplt",
                                            Template_Data);
         Output_Path : constant String :=
           Model.Configuration.Output_Dir.Element;
         Filename    : constant String := Output_Path & "/build-script.sh";
         Output      : File_Type;
      begin
         Create_Path (Output_Path);
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
