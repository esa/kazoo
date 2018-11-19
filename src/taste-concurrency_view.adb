--  *************************** taste aadl parser ***********************  --
--  (c) 2018 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

--  Concurrency View

with Ada.Directories,
     Ada.IO_Exceptions,
     Ada.Exceptions;

use Ada.Directories;

package body TASTE.Concurrency_View is

   procedure Debug_Dump (CV : Taste_Concurrency_View; Output : File_Type) is
   begin
      for Block of CV.Blocks loop
         Put_Line (Output, "Protected Block : " & To_String (Block.Name));
         for Provided of Block.Provided loop
            Put_Line (Output, " |_ PI : " & To_String (Provided.Name));
         end loop;
         for Required of Block.Required loop
            Put_Line (Output, " |_ RI : " & To_String (Required.Name));
         end loop;
         for Thread of Block.Calling_Threads loop
            Put_Line (Output, " |_ Calling_Thread : " & Thread);
         end loop;
         Put_Line (Output, " |_ Node : "
                   & To_String (Block.Node.Value_Or
                     (Taste_Node'(Name => US ("(none)"), others => <>)).Name));
      end loop;

      for Thread of CV.Threads loop
         Put_Line (Output, "Thread : " & To_String (Thread.Name));
         Put_Line (Output, " |_ Port : " & To_String (Thread.Entry_Port_Name));
         Put_Line (Output, " |_ Protected Block : "
                   & To_String (Thread.Protected_Block_Name));
         Put_Line (Output, " |_ Node : "
                   & To_String (Thread.Node.Value_Or
                     (Taste_Node'(Name => US ("(none)"), others => <>)).Name));
         for Out_Port of Thread.Output_Ports loop
            Put_Line (Output, " |_ Output port remote thread : "
                      & To_String (Out_Port.Remote_Thread));
            Put_Line (Output, " |_ Output port remote PI : "
                      & To_String (Out_Port.Remote_PI));
         end loop;
      end loop;
   end Debug_Dump;

   --  This function translates a protected block into a template
   function To_Template (B : Protected_Block) return Block_As_Template is
      Calling_Threads : Tag;
      Result : Block_As_Template;
   begin
      for Thread of B.Calling_Threads loop
         Calling_Threads := Calling_Threads & Thread;
      end loop;

      for PI of B.Provided loop
         declare
            Basic : constant Translate_Set := PI.PI.To_Template
              & Assoc ("Protected_Block_Name", To_String (PI.Name))
              & Assoc ("Caller_Is_Local", PI.Local_Caller);
         begin
            Result.Provided.Append (Basic);
         end;
      end loop;

      for RI of B.Required loop
         Result.Required.Append (RI.To_Template);
      end loop;

      Result.Header := +Assoc  ("Name",            To_String (B.Name))
                       & Assoc ("Calling_Threads", Calling_Threads)
                       & Assoc ("Node_Name",       To_String (B.Node.Value_Or
                         (Taste_Node'(Name => US (""), others => <>)).Name));
      return Result;
   end To_Template;

   --  This function translates a thread definition into a template
   function To_Template (T : AADL_Thread) return Translate_Set is
      Remote_Thread : Vector_Tag;
      Remote_PI     : Vector_Tag;
      Ports_Matrix  : Matrix_Tag;
   begin
      for Out_Port of T.Output_Ports loop
         Remote_Thread := Remote_Thread & To_String (Out_Port.Remote_Thread);
         Remote_PI     := Remote_PI     & To_String (Out_Port.Remote_PI);
      end loop;

      Ports_Matrix := +Remote_Thread & Remote_PI;

      return Result : constant Translate_Set :=
        (+Assoc  ("Name",            To_String (T.Name))
         & Assoc ("Entry_Port_Name", To_String (T.Entry_Port_Name))
         & Assoc ("Pro_Block_Name",  To_String (T.Protected_Block_Name))
         & Assoc ("Node_Name",       To_String (T.Node.Value_Or
           (Taste_Node'(Name => US (""), others => <>)).Name))
         & Assoc ("Out_Ports",       Ports_Matrix));
   end To_Template;

   function Concurrency_View_Template (CV : Taste_Concurrency_View)
                                       return CV_As_Template
   is
      Result : CV_As_Template;
   begin
      for Thread of CV.Threads loop
         Result.Threads.Append (Thread.To_Template);
      end loop;
      for Pro of CV.Blocks loop
         Result.Blocks.Append (Pro.To_Template);
      end loop;
      return Result;
   end Concurrency_View_Template;

   --  Parse the template files to generate the CV output with Templates_parser
   procedure Generate_CV (CV                 : Taste_Concurrency_View;
                          Base_Template_Path : String;
                          Base_Output_Path   : String)
   is
      Prefix   : constant String := Base_Template_Path
        & "templates/concurrency_view";
      Template : constant CV_As_Template := CV.Concurrency_View_Template;
      pragma Unreferenced (Template);
      --  To iterate over template folders
      ST       : Search_Type;
      Current  : Directory_Entry_Type;
      Filter   : constant Filter_Type := (Directory => True,
                                          others    => False);
      Output_File : File_Type;
      Output_Dir  : constant String := Base_Output_Path & "/concurrency_view/";
   begin
      Put_Info ("Generating Concurrency View");
      --  All files are created in the same folder - create it
      Create_Path (Output_Dir);

      Start_Search (Search    => ST,
                    Pattern   => "",
                    Directory => Prefix,
                    Filter    => Filter);

      if not More_Entries (ST) then
         --  On Unix, this will never happen because "." and ".." are part
         --  of the search result. We'll only get an IO Error if the
         --  concurrency_view folder itself does not exist
         raise Concurrency_View_Error with
           "No folders with templates for concurrency view";
      end if;

      --  Iterate over the folders and process templates
      while More_Entries (ST) loop
         Get_Next_Entry (ST, Current);

         --  Ignore Unix special directories
         if Simple_Name (Current) = "." or Simple_Name (Current) = ".." then
            goto continue;
         end if;

         declare
            Path : constant String := Full_Name (Current);
            Do_It : constant Boolean := Exists (Path & "/filename.tmplt");
            --  Get output file name from template
            File_Name : constant String :=
              (if Do_It then
                  Strip_String (Parse (Path & "/filename.tmplt"))
               else "");
            --  Check if file already exists
            Present : constant Boolean :=
              (File_Name /= "" and Exists (Output_Dir & File_Name));
            Trig_Tmpl : constant Translate_Set :=
              +Assoc ("Filename_Is_Present", Present);
            Trigger : constant Boolean :=
              (Exists (Path & "/trigger.tmplt") and then
               Strip_String
                 (Parse (Path & "/trigger.tmplt", Trig_Tmpl)) = "TRUE");
         begin
            if Trigger then
               Put_Info ("Generating from " & Path);
               Create (File => Output_File,
                       Mode => Out_File,
                       Name => Output_Dir & File_Name);
               Put_Line (Output_File, "Hello");
               Close (Output_File);
            end if;
         end;
         <<continue>>
      end loop;
      End_Search (ST);
   exception
      when Error : Concurrency_View_Error | Ada.IO_Exceptions.Name_Error =>
         Put_Error ("Concurrency View : "
                    & Ada.Exceptions.Exception_Message (Error));
         raise Quit_Taste;
   end Generate_CV;
end TASTE.Concurrency_View;
