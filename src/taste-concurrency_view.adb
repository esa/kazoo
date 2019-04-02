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
      procedure Dump_Partition (Partition : CV_Partition) is
      begin
         for Block of Partition.Blocks loop
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
            if Block.Node.Has_Value then
               Put_Line (Output, " |_ Node : "
                         & To_String (Block.Node.Unsafe_Just.Name));
               declare
                  P : constant Taste_Partition :=
                    Block.Node.Unsafe_Just.Find_Partition
                      (To_String (Block.Name)).Unsafe_Just;
               begin
                  Put_Line (Output, " |_ Partition : " & To_String (P.Name));
                  Put_Line (Output, "   |_ Coverage       : "
                            & P.Coverage'Img);
                  Put_Line (Output, "   |_ Package        : "
                            & To_String (P.Package_Name));
                  Put_Line (Output, "   |_ CPU Name       : "
                            & To_String (P.CPU_Name));
                  Put_Line (Output, "   |_ CPU Platform   : "
                            & P.CPU_Platform'Img);
                  Put_Line (Output, "   |_ CPU Classifier : "
                            & To_String (P.CPU_Classifier));
               end;
            end if;
         end loop;

         for Thread of Partition.Threads loop
            Put_Line (Output, "Thread : " & To_String (Thread.Name));
            Put_Line (Output, " |_ Port : "
                      & To_String (Thread.Entry_Port_Name));
            Put_Line (Output, " |_ Protected Block : "
                      & To_String (Thread.Protected_Block_Name));
            Put_Line (Output, " |_ Node : "
                      & To_String (Thread.Node.Value_Or
                        (Taste_Node'(Name   => US ("(none)"),
                                     others => <>)).Name));
            for Out_Port of Thread.Output_Ports loop
               Put_Line (Output, " |_ Output port remote thread : "
                         & To_String (Out_Port.Remote_Thread));
               Put_Line (Output, " |_ Output port remote PI : "
                         & To_String (Out_Port.Remote_PI));
            end loop;
         end loop;
      end Dump_Partition;
   begin
      for Node of CV.Nodes loop
         for Partition of Node.Partitions loop
            Dump_Partition (Partition);
         end loop;
      end loop;
   end Debug_Dump;

   --  This function translates a protected block into a template
   function Prepare_Template (B : Protected_Block) return Block_As_Template is
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
   end Prepare_Template;

   --  This function translates a thread definition into a template
   function To_Template (T : AADL_Thread) return Translate_Set is
      Remote_Thread : Vector_Tag;
      Remote_PI     : Vector_Tag;
   begin
      for Out_Port of T.Output_Ports loop
         Remote_Thread := Remote_Thread & To_String (Out_Port.Remote_Thread);
         Remote_PI     := Remote_PI     & To_String (Out_Port.Remote_PI);
      end loop;

      return Result : constant Translate_Set :=
        (+Assoc  ("Name",            To_String (T.Name))
         & Assoc ("Entry_Port_Name", To_String (T.Entry_Port_Name))
         & Assoc ("Pro_Block_Name",  To_String (T.Protected_Block_Name))
         & Assoc ("Node_Name",       To_String (T.Node.Value_Or
           (Taste_Node'(Name => US (""), others => <>)).Name))
         & Assoc ("Remote_Threads",  Remote_Thread)
         & Assoc ("Remote_PIs",      Remote_PI));
   end To_Template;

   --  Generate the output file for one node
   procedure Generate_Node (CV : Taste_Concurrency_View; Node_Name : String)
   is
      Prefix   : constant String := CV.Base_Template_Path.Element
        & "templates/concurrency_view";
      --  To iterate over template folders
      ST       : Search_Type;
      Current  : Directory_Entry_Type;
      Filter   : constant Filter_Type := (Directory => True,
                                          others    => False);
      Output_File : File_Type;
      Output_Dir  : constant String :=
        CV.Base_Output_Path.Element & "/concurrency_view/" & Node_Name;
   begin
      Put_Info ("Generating Concurrency View for node " & Node_Name);
      --  All files for one node are created in the same folder - create it
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
            Path  : constant String  := Full_Name (Current);
            Do_It : constant Boolean := Exists (Path & "/filename.tmplt");
            Filename_Set : constant Translate_Set :=
              +Assoc ("Node_Name", Node_Name);
            --  Get output file name from template
            File_Name : constant String :=
              (if Do_It then
                  Strip_String (Parse (Path & "/filename.tmplt", Filename_Set))
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

            function Generate_Partition (Partition_Name : String)
                                         return String
            is
               Partition       : constant CV_Partition :=
                 CV.Nodes (Node_Name).Partitions (Partition_Name);
               Threads         : Tag;
               Blocks          : Tag;
               Partition_Assoc : Translate_Set;
            begin
               for T of Partition.Threads loop
                  declare
                     --  Render each thread
                     Thread_Assoc : constant Translate_Set := T.To_Template;
                     Result : constant String :=
                       (Parse (Path & "/thread.tmplt", Thread_Assoc));
                  begin
                     Threads := Threads & Result;
                  end;
               end loop;
               for B of Partition.Blocks loop
                  declare
                     Tmpl : constant Block_As_Template := B.Prepare_Template;
                     Block_Assoc : Translate_Set := Tmpl.Header;
                     PI_Tag : Tag;
                     RI_Tag : Tag;
                  begin
                     for PI_Assoc of Tmpl.Provided loop
                        PI_Tag := PI_Tag
                          & String'(Parse (Path & "/pi.tmplt", PI_Assoc));
                     end loop;
                     for RI_Assoc of Tmpl.Required loop
                        RI_Tag := RI_Tag
                          & String'(Parse (Path & "/ri.tmplt", RI_Assoc));
                     end loop;
                     Block_Assoc := Block_Assoc
                       & Assoc ("Provided", PI_Tag)
                       & Assoc ("Required", RI_Tag);

                     Blocks := Blocks &
                       String'(Parse (Path & "/block.tmplt", Block_Assoc));
                  end;
               end loop;
               --  Association includes Name, Coverage, CPU Info, etc.
               --  (see taste-deployment_view.ads for the complete list)
               Partition_Assoc := Partition.Deployment_Partition.To_Template
                 & Assoc ("Threads", Threads)
                 & Assoc ("Blocks",   Blocks);

               return Parse (Path & "/partition.tmplt", Partition_Assoc);
            end Generate_Partition;

            Partitions : Tag;
            Node_Assoc : Translate_Set;

         begin
            if Trigger then
               for Partition in CV.Nodes (Node_Name).Partitions.Iterate loop
                  Partitions := Partitions
                    & Generate_Partition (CV_Partitions.Key (Partition));
               end loop;
               Node_Assoc := +Assoc ("Partitions", Partitions)
                  & Assoc ("Node_Name", Node_Name);

               Put_Info ("Generating from " & Path);
               Create (File => Output_File,
                       Mode => Out_File,
                       Name => Output_Dir & "/" & File_Name);
               Put_Line (Output_File,
                         Parse (Path & "/node.tmplt", Node_Assoc));
               Close (Output_File);
            end if;
         end;
         <<continue>>
      end loop;
      End_Search (ST);
   end Generate_Node;
   procedure Generate_System (CV : Taste_Concurrency_View) is
   begin
      null;
   end Generate_System;

   procedure Generate_CV (CV : Taste_Concurrency_View) is
   begin
      --  In this first iteration Nodes are generated in standalone files,
      --  and they include their processes. It would be useful to be able
      --  to decide if processes could also have their own files, since
      --  in the future they may be more than one process per node (for TSP).
      for Node in CV.Nodes.Iterate loop
         if CV_Nodes.Key (Node) /= "interfaceview" then
            CV.Generate_Node (CV_Nodes.Key (Node));
         end if;
      end loop;
      CV.Generate_System;
   exception
      when Error : Concurrency_View_Error | Ada.IO_Exceptions.Name_Error =>
         Put_Error ("Concurrency View : "
                    & Ada.Exceptions.Exception_Message (Error));
         raise Quit_Taste;
   end Generate_CV;

end TASTE.Concurrency_View;
