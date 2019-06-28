--  *************************** kazoo ***********************  --
--  (c) 2019 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

with Ada.Directories,
     Ada.Text_IO,
     Ada.Characters.Latin_1,
     Ada.Exceptions,
     Ada.Strings.Unbounded,
     Templates_Parser,
     TASTE.Parser_Utils,
     TASTE.Backend.Code_Generators;

use Ada.Directories,
    Ada.Text_IO,
    Ada.Strings.Unbounded,
    Templates_Parser,
    TASTE.Parser_Utils,
    TASTE.Backend.Code_Generators;

package body TASTE.Dump is

   Newline : Character renames Ada.Characters.Latin_1.LF;

   --  iterate over template folders
   procedure Dump_Everything (Model : TASTE_Model)
   is
      IV : constant IV_As_Template :=
        Interface_View_Template (Model.Interface_View);

      --  Everything will be generated under output/Dump
      --  There may be subfolders inside, set by the templates
      Output_Prefix : constant String :=
        Model.Configuration.Output_Dir.Element & "/Dump";

      --  Root path containing the template subfolders:
      Prefix   : constant String :=
        Model.Configuration.Binary_Path.Element & "templates/dump";

      --  To iterate over template folders
      ST       : Search_Type;
      Current  : Directory_Entry_Type;
      Filter   : constant Filter_Type := (Directory => True,
                                          others    => False);
      Output_File      : File_Type;

      --  output path will be determined by the templates
      --  CV_Out_Dir  : constant String  :=
      --   CV.Base_Output_Path.Element & "/concurrency_view/";

      --  Tags that are built over the whole system
      --  and cleant up between each template folder:
   begin
      Start_Search (Search    => ST,
                    Pattern   => "",
                    Directory => Prefix,
                    Filter    => Filter);

      if not More_Entries (ST) then
         --  On Unix, this will never happen because "." and ".." are part
         --  of the search result. We'll only get an IO Error if the
         --  dump folder itself does not exist
         raise Dump_Error with
           "No folders with templates to dump input models";
      end if;

      --  Iterate over the folders containing template files
      while More_Entries (ST) loop
         --  Clean-up system-wise tags before the next template folder:

         Get_Next_Entry (ST, Current);

         --  Ignore Unix special directories
         if Simple_Name (Current) = "." or Simple_Name (Current) = ".." then
            goto continue;
         end if;

         declare
            Path          : constant String := Full_Name (Current);
            Path_Template : constant String := Path & "/path.tmplt";
            File_Template : constant String := Path & "/filename.tmplt";
            Trig_Template : constant String := Path & "/trigger.tmplt";
            Out_Template  : constant String := Path & "/output.tmplt";
            IV_Template   : constant String := Path & "/interfaceview.tmplt";
            DV_Template   : constant String := Path & "/deploymentview.tmplt";
            Data_Template : constant String := Path & "/dataview.tmplt";
            Func_Template : constant String := Path & "/function.tmplt";
            IF_Template   : constant String := Path & "/interface.tmplt";

            --  Verify that all templates files are present
            Check         : constant Boolean :=
              Exists (Path_Template) and then Exists (File_Template)
              and then Exists (Trig_Template) and then Exists (Out_Template)
              and then Exists (IV_Template) and then Exists (DV_Template)
              and then Exists (Data_Template) and then Exists (Func_Template)
              and then Exists (IF_Template);

            --  Get the output path and filename from the template,
            --  and evaluate the trigger condition
            --  (in the future it should get the configuration as tags)
            Output_Path   : constant String :=
              (if Check then Strip_String (Parse (Path_Template)) else "");
            Filename      : constant String :=
              (if Check then Strip_String (Parse (File_Template)) else "");
            Trigger       : constant Boolean :=
              (Check and then (Strip_String (Parse (Trig_Template)) = "TRUE"));

            IV_Tags     : Translate_Set;
            Output_Tags : Translate_Set;
            Functions   : Unbounded_String;

            function Process_Interfaces (Interfaces : St_Interfaces.Vector)
                                         return Unbounded_String
            is
               Result : Unbounded_String;
            begin
               for I of Interfaces loop
                  Result := Result & String'(Parse (IF_Template, I)) & Newline;
               end loop;
               return Result;
            end Process_Interfaces;

         begin
            if not Check or not Trigger then
               Put_Info ("Nothing generated from " & Path);
               return;
            else
               Put_Info ("Generating Dump from " & Path);
               for F of IV.Funcs loop
                  declare
                     Func_Map : constant Translate_Set := F.Header
                       & Assoc ("Provided_Interfaces",
                                Process_Interfaces (F.Provided))
                       & Assoc ("Required_Interfaces",
                                Process_Interfaces (F.Required));
                     Result : constant String :=
                       Parse (Func_Template, Func_Map);
                  begin
                     Functions := Functions & Result & Newline;
                  end;
               end loop;
            end if;
            IV_Tags     := +Assoc ("Functions", Functions);
            Output_Tags := +Assoc
              ("Interface_View", String'(Parse (IV_Template, IV_Tags)));
            Create_Path (Output_Prefix & "/" & Output_Path);
            Create (File => Output_File,
                    Mode => Out_File,
                    Name =>
                      Output_Prefix & "/" & Output_Path & "/" & Filename);
            Put_Line (Output_File, Parse (Out_Template, Output_Tags));
            Close (Output_File);
         end;

         <<continue>>
      end loop;
      End_Search (ST);
   end Dump_Everything;

   procedure Dump_Input_Model (Model : TASTE_Model) is
   begin
      Dump_Everything (Model);
   exception
      when Error : others =>
         Put_Error ("Dump : "
                    & Ada.Exceptions.Exception_Message (Error));
         raise Quit_Taste;
   end Dump_Input_Model;

end TASTE.Dump;
