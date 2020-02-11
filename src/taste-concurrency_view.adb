--  *************************** kazoo ***********************  --
--  (c) 2019 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

with Ada.Directories,
     Ada.IO_Exceptions,
     Ada.Exceptions,
     Ada.Characters.Latin_1,
     --  Ada.Strings.Fixed,
     GNAT.Directory_Operations,   -- Contains Dir_Name
     TASTE.Backend;

use Ada.Directories,
    GNAT.Directory_Operations;

package body TASTE.Concurrency_View is

   Newline : Character renames Ada.Characters.Latin_1.LF;

   procedure Debug_Dump (CV : Taste_Concurrency_View; Output : File_Type) is
      procedure Dump_Partition (Partition : CV_Partition) is
      begin
         for Block of Partition.Blocks loop
            Put_Line (Output, "Protected Block : "
                      & To_String (Block.Ref_Function.Name));
            for Provided of Block.Block_Provided loop
               Put_Line (Output, " |_ PI : " & To_String (Provided.Name));
            end loop;
            for Required of Block.Ref_Function.Required loop
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
                      (To_String (Block.Ref_Function.Name)).Unsafe_Just;
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
   function Prepare_Block_Template (B : Protected_Block)
                                    return Block_As_Template
   is
      Calling_Threads : Tag;
      Result          : Block_As_Template;
   begin
      for Thread of B.Calling_Threads loop
         Calling_Threads := Calling_Threads & Thread;
      end loop;

      for PI of B.Block_Provided loop
         declare
            Basic : constant Translate_Set := PI.PI.Interface_To_Template
              & Assoc ("Protected_Block_Name", To_String (PI.Name))
              & Assoc ("Caller_Is_Local", PI.Local_Caller)
              & Assoc ("Calling_Threads", Calling_Threads);
         begin
            if PI.PI.RCM = Protected_Operation then
               Result.Protected_Provided.Append (Basic);
            else
               Result.Unprotected_Provided.Append (Basic);
            end if;
         end;
      end loop;

      for RI of B.Ref_Function.Required loop
         Result.Required.Append (RI.Interface_To_Template
                                 & Assoc ("Calling_Threads", Calling_Threads));
      end loop;

      Result.Header := B.Ref_Function.Function_To_Template.Header
                       & Assoc ("Calling_Threads", Calling_Threads)
                       & Assoc ("Node_Name",       To_String (B.Node.Value_Or
                         (Taste_Node'(Name => US (""), others => <>)).Name));
      return Result;
   end Prepare_Block_Template;

   --  This function translates a thread definition into a template
   function To_Template (T : AADL_Thread) return Translate_Set is
      Remote_Thread    : Vector_Tag;
      RI_Port_Name     : Vector_Tag;  --  Name of the local RI (= port name)
      Remote_PI        : Vector_Tag;  --  Name of the remote PI
      Remote_PI_Sort   : Vector_Tag;  --  ASN.1 type of the parameter
      Remote_PI_Module : Vector_Tag;  --  ASN.1 module containing the type
   begin
      for Out_Port of T.Output_Ports loop
         RI_Port_Name  := RI_Port_Name & Out_Port.Name;
         Remote_Thread := Remote_Thread & To_String (Out_Port.Remote_Thread);
         Remote_PI     := Remote_PI     & To_String (Out_Port.Remote_PI);
         --  Set the Asn.1 module and type of the optional RI parameter
         if Out_Port.RI.Params.Length > 0 then
            Remote_PI_Sort := Remote_PI_Sort
              & Out_Port.RI.Params.First_Element.Sort;
            Remote_PI_Module := Remote_PI_Module
              & Out_Port.RI.Params.First_Element.ASN1_Module;
         else
            Remote_PI_Sort   := Remote_PI_Sort   & "";
            Remote_PI_Module := Remote_PI_Module & "";
         end if;
      end loop;

      return Result : constant Translate_Set :=
        T.PI.Interface_To_Template      --  PI used to create the thread
        & Assoc ("Thread_Name",         To_String (T.Name))
        & Assoc ("Partition_Name",      To_String (T.Partition_Name))
        & Assoc ("Entry_Port_Name",     To_String (T.Entry_Port_Name))
        & Assoc ("RCM",                 To_String (T.RCM))
        & Assoc ("Need_Mutex",          T.Need_Mutex)
        & Assoc ("Pro_Block_Name",      To_String (T.Protected_Block_Name))
        & Assoc ("Node_Name",           To_String (T.Node.Value_Or
          (Taste_Node'(Name => US (""), others => <>)).Name))
        & Assoc ("Remote_Threads",      Remote_Thread)
        & Assoc ("RI_Port_Names",       RI_Port_Name)
        & Assoc ("Remote_PIs",          Remote_PI)
        & Assoc ("Remote_PI_Sorts",     Remote_PI_Sort)
        & Assoc ("Remote_PI_Modules",   Remote_PI_Module)
        & Assoc ("Priority",            To_String (T.Priority))
        & Assoc ("Dispatch_Offset_ms",  To_String (T.Dispatch_Offset_Ms))
        & Assoc ("Stack_Size_In_Bytes", To_String (T.Stack_Size_In_Bytes));
   end To_Template;

   --  Generate the code by iterating over template folders
   procedure Generate_Code (CV : Taste_Concurrency_View)
   is
      Prefix   : constant String := CV.Base_Template_Path.Element
        & "templates/concurrency_view";
      --  To iterate over template folders
      ST       : Search_Type;
      Current  : Directory_Entry_Type;
      Filter   : constant Filter_Type := (Directory => True,
                                          others    => False);
      Output_File      : File_Type;

      CV_Out_Dir  : constant String  :=
        CV.Base_Output_Path.Element & "/build/";

      --  Tags that are built over the whole system
      --  and cleant up between each template folder:
      Threads          : Unbounded_String;
      All_Thread_Names : Tag;  --  Complete list of threads
      All_Target_Names : Tag;  --  List of all targets used (AADL packages)
      All_Block_Names  : Tag;  --  Complete list of blocks
   begin
      Put_Debug ("Concurrency View templates expected in " & Prefix);
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

      --  Iterate over the folders containing template files
      while More_Entries (ST) loop
         --  Clean-up system-wise tags before the next template folder:
         Threads := US ("");
         Clear (All_Thread_Names);
         Clear (All_Target_Names);
         Clear (All_Block_Names);

         Get_Next_Entry (ST, Current);

         --  Ignore Unix special directories
         if Simple_Name (Current) = "." or Simple_Name (Current) = ".." then
            goto continue;
         end if;

         declare
            Path  : constant String  := Full_Name (Current);

            function Generate_Partition (Node_Name      : String;
                                         Partition_Name : String)
                                         return String
            is
               Partition       : constant CV_Partition :=
                 CV.Nodes (Node_Name).Partitions (Partition_Name);
               Thread_Names,
               Thread_Has_Param : Vector_Tag;
               Block_Names,
               Block_Languages,
               Block_Instance_Of : Vector_Tag;
               Blocks          : Unbounded_String;
               Part_Threads    : Unbounded_String;
               Partition_Assoc : Translate_Set;
               --  Connections between threads:
               Thread_Src_Name,
               Thread_Src_Port : Vector_Tag;
               Thread_Dst_Name,
               Thread_Dst_Port : Vector_Tag;
               Input_Port_Names,
               Input_Port_Type_Name,
               Input_Port_Thread_Name  : Vector_Tag;
               Output_Port_Names,
               Output_Port_Type_Name   : Vector_Tag;
               Part_Out_Port_Names,  --  there can be multiple threads
               Connected_Threads : Vector_Tag;  -- on one partition outport

               --  Optionally generate partition code in separate files
               --  (if filepart.tmplt is present and contains a filename)
               File_Id         : constant String := Path & "/filepart.tmplt";
               Part_Check      : constant Boolean := Exists (File_Id);
               Part_Tag        : constant Translate_Set :=
                 +Assoc ("Partition_Name", Partition_Name);
               Part_File_Name  : constant String :=
                 (if Part_Check then Strip_String (Parse (File_Id, Part_Tag))
                  else "");
               Part_Content    : Unbounded_String;
            begin
               Document_Template
                 (Templates_Concurrency_View_Sub_File_Part, Part_Tag);
               for Each of Partition.In_Ports loop
                  Input_Port_Names := Input_Port_Names & Each.Port_Name;
                  Input_Port_Type_Name := Input_Port_Type_Name
                    & Each.Type_Name;
                  Input_Port_Thread_Name :=
                    Input_Port_Thread_Name & Each.Thread_Name;
               end loop;
               for Each of Partition.Out_Ports loop
                  Output_Port_Names := Output_Port_Names & Each.Port_Name;
                  Output_Port_Type_Name := Output_Port_Type_Name
                    & Each.Type_Name;
                  --  Set the connection between threads and partition outports
                  for T of Each.Connected_Threads loop
                     Part_Out_Port_Names := Part_Out_Port_Names
                       & Each.Port_Name;
                     Connected_Threads := Connected_Threads & T;
                  end loop;
               end loop;

               for T of Partition.Threads loop
                  declare
                     --  Render each thread
                     Name         : constant String := To_String (T.Name);
                     Thread_Assoc : constant Translate_Set :=
                       Join_Sets (T.To_Template, CV.Configuration.To_Template);
                     Result       : constant String :=
                       (Parse (Path & "/thread.tmplt", Thread_Assoc));

                     --  Optionally generate thread code in separate files
                     --  (if filethread.tmplt present and contains a filename)
                     Thread_File_Id   : constant String :=
                       Path & "/filethread.tmplt";
                     Thread_Check     : constant Boolean :=
                       Exists (Thread_File_Id);
                     Thread_Tag       : constant Translate_Set :=
                       +Assoc ("Thread_Name", Name)
                       & Assoc ("Partition_Name", Partition_Name);
                     Thread_File_Name : constant String :=
                       (if Thread_Check
                        then Strip_String (Parse (Thread_File_Id, Thread_Tag))
                        else "");
                  begin
                     Document_Template
                       (Templates_Concurrency_View_Sub_Thread, Thread_Assoc);
                     Document_Template
                       (Templates_Concurrency_View_Sub_File_Thread,
                        Thread_Tag);

                     Threads      := Threads & Newline & Result;
                     Part_Threads := Part_Threads & Newline & Result;
                     Thread_Names := Thread_Names & Name;
                     --  Set boolean to true if thread has a param
                     --  That helps backend to know if POHI has generated
                     --  the "types" package.
                     Thread_Has_Param := Thread_Has_Param &
                       (T.PI.Params.Length > 0);

                     All_Thread_Names := All_Thread_Names & Name;
                     for P of T.Output_Ports loop
                        for Part_Threads of Partition.Threads loop
                           --  Create partition ports only when source and
                           --  destination are in the same partition
                           if P.Remote_Thread = Part_Threads.Name then
                              Thread_Src_Name := Thread_Src_Name & Name;
                              Thread_Src_Port := Thread_Src_Port
                                & To_String (P.Name);
                              Thread_Dst_Name := Thread_Dst_Name
                                & To_String (P.Remote_Thread);
                              Thread_Dst_Port := Thread_Dst_Port
                                & To_String (P.Remote_PI);
                           end if;
                        end loop;
                     end loop;
                     --  Save the content of the thread in a file
                     --  (if required at template folder level)
                     if Thread_File_Name /= "" then
                        Create_Path (CV_Out_Dir & Node_Name & Dir_Separator
                                       & Dir_Name (Thread_File_Name));
                        Create (File => Output_File,
                                Mode => Out_File,
                                Name => CV_Out_Dir
                                  & Node_Name & Dir_Separator
                                  & Thread_File_Name);
                        Put_Line (Output_File, Result);
                        Close (Output_File);
                     end if;
                  end;
               end loop;

               for B of Partition.Blocks loop
                  declare
                     Block_Name   : constant String :=
                       To_String (B.Ref_Function.Name);
                     Tmpl         : constant Block_As_Template :=
                       B.Prepare_Block_Template;
                     Block_Assoc  : Translate_Set := Tmpl.Header;
                     Pro_PI_Tag   : Unbounded_String;
                     Unpro_PI_Tag : Unbounded_String;
                     RI_Tag       : Unbounded_String;
                     Result       : Unbounded_String;

                     --  Optionally generate block code in separate files
                     --  (if fileblock.tmplt present and contains a filename)
                     Block_File_Id   : constant String :=
                       Path & "/fileblock.tmplt";
                     Block_Check     : constant Boolean :=
                       Exists (Block_File_Id);
                     Block_Tag       : constant Translate_Set :=
                       +Assoc ("Block_Name", Block_Name);
                     Block_File_Name : constant String :=
                       (if Block_Check
                        then Strip_String (Parse (Block_File_Id, Block_Tag))
                        else "");
                  begin
                     Document_Template
                       (Templates_Concurrency_View_Sub_File_Block, Block_Tag);
                     Block_Names     := Block_Names & Block_Name;
                     All_Block_Names := All_Block_Names & Block_Name;
                     Block_Languages := Block_Languages
                       & TASTE.Backend.Language_Spelling (B.Ref_Function);
                     Block_Instance_Of := Block_Instance_Of
                       & B.Ref_Function.Instance_Of.Value_Or (US (""));

                     for PI_Assoc of Tmpl.Protected_Provided loop
                        Document_Template
                          (Templates_Concurrency_View_Sub_PI,
                           PI_Assoc & Assoc ("Partition_Name", ""));
                        Pro_PI_Tag := Pro_PI_Tag & Newline
                          & String'(Parse (Path & "/pi.tmplt",
                                    PI_Assoc & Assoc
                                      ("Partition_Name", Partition_Name)));
                     end loop;
                     for PI_Assoc of Tmpl.Unprotected_Provided loop
                        Unpro_PI_Tag := Unpro_PI_Tag & Newline
                          & String'(Parse (Path & "/pi.tmplt",
                                    PI_Assoc & Assoc
                                      ("Partition_Name", Partition_Name)));
                     end loop;
                     for RI_Assoc of Tmpl.Required loop
                        Document_Template
                          (Templates_Concurrency_View_Sub_RI,
                           RI_Assoc & Assoc ("Partition_Name", ""));

                        RI_Tag := RI_Tag & Newline
                          & String'(Parse (Path & "/ri.tmplt",
                                    RI_Assoc & Assoc
                                      ("Partition_Name", Partition_Name)));
                     end loop;

                     Block_Assoc :=
                       Join_Sets (Block_Assoc, CV.Configuration.To_Template)
                       & Assoc ("Partition_Name",
                                Partition.Deployment_Partition.Name)
                       & Assoc ("Protected_PIs",   Pro_PI_Tag)
                       & Assoc ("Unprotected_PIs", Unpro_PI_Tag)
                       & Assoc ("Required",        RI_Tag);

                     Result := Parse (Path & "/block.tmplt", Block_Assoc);
                     Document_Template
                       (Templates_Concurrency_View_Sub_Block, Block_Assoc);

                     Blocks := Blocks & Newline & To_String (Result);

                     --  Save the content of the block in a file
                     --  (if required at template folder level)
                     if Block_File_Name /= "" then
                        Create_Path (CV_Out_Dir & Node_Name
                                       & Dir_Separator
                                       & Dir_Name (Block_File_Name));
                        Create (File => Output_File,
                                Mode => Out_File,
                                Name => CV_Out_Dir
                                  & Node_Name & Dir_Separator
                                  & Block_File_Name);
                        Put_Line (Output_File, To_String (Result));
                        Close (Output_File);
                     end if;
                  end;
               end loop;
               --  Association includes Name, Coverage, CPU Info, etc.
               --  (see taste-deployment_view.ads for the complete list)
               Partition_Assoc := Join_Sets (Partition.Deployment_Partition
                                               .To_Template,
                                             Drivers_To_Template
                                               (CV.Nodes (Node_Name)
                                                  .Deployment_Node.Drivers))
                 & Assoc ("Threads",              Part_Threads)
                 & Assoc ("Thread_Names",         Thread_Names)
                 & Assoc ("Thread_Has_Param",     Thread_Has_Param)
                 & Assoc ("Node_Name",            Node_Name)
                 & Assoc ("Blocks",               Blocks)
                 & Assoc ("Block_Names",          Block_Names)
                 & Assoc ("Block_Languages",      Block_Languages)
                 & Assoc ("Block_Instance_Of",    Block_Instance_Of)
                 & Assoc ("In_Port_Names",        Input_Port_Names)
                 & Assoc ("In_Port_Thread_Name",  Input_Port_Thread_Name)
                 & Assoc ("In_Port_Type_Name",    Input_Port_Type_Name)
                 & Assoc ("Out_Port_Names",       Output_Port_Names)
                 & Assoc ("Out_Port_Type_Name",   Output_Port_Type_Name)
                 & Assoc ("Part_Out_Port_Name",   Part_Out_Port_Names)
                 & Assoc ("Connected_Threads",    Connected_Threads)
                 & Assoc ("Thread_Src_Name",      Thread_Src_Name)
                 & Assoc ("Thread_Src_Port",      Thread_Src_Port)
                 & Assoc ("Thread_Dst_Name",      Thread_Dst_Name)
                 & Assoc ("Thread_Dst_Port",      Thread_Dst_Port);

               All_Target_Names := All_Target_Names
                 & String'(Get (Get (Partition_Assoc, "Package_Name")));

               Part_Content :=
                 Parse (Path & "/partition.tmplt", Partition_Assoc);

               Document_Template
                 (Templates_Concurrency_View_Sub_Partition, Partition_Assoc);

               --  Save the content of the partition in a file
               --  (if required at template folder level)
               if Part_File_Name /= "" then
                  Create_Path (CV_Out_Dir & Node_Name
                               & Dir_Separator & Dir_Name (Part_File_Name));
                  Create (File => Output_File,
                          Mode => Out_File,
                          Name => CV_Out_Dir
                             & Node_Name & Dir_Separator & Part_File_Name);
                  Put_Line (Output_File, To_String (Part_Content));
                  Close (Output_File);
               end if;

               return To_String (Part_Content);
            end Generate_Partition;

            --  Generate the code for one node
            function Generate_Node (Node_Name : String) return String is
               Partitions      : Unbounded_String;
               Partition_Names : Tag;
               Node_Assoc      : Translate_Set;
               --  Nodes may contain a list of virtual processors for TSP:
               VP_Names,
               VP_Package_Names,
               VP_Platforms,
               VP_Classifiers  : Vector_Tag;
            begin
               for Partition in CV.Nodes (Node_Name).Partitions.Iterate loop
                  Partition_Names := Partition_Names
                    & CV_Partitions.Key (Partition);
                  Partitions := Partitions & Newline
                    & Generate_Partition
                    (Partition_Name => CV_Partitions.Key (Partition),
                     Node_Name      => Node_Name);
               end loop;
               for VP of CV.Nodes (Node_Name).Deployment_Node.Virtual_CPUs loop
                  VP_Names         := VP_Names & VP.Name;
                  VP_Package_Names := VP_Package_Names & VP.Package_Name;
                  VP_Platforms     := VP_Platforms & VP.Platform;
                  VP_Classifiers   := VP_Classifiers & VP.Classifier;
               end loop;

               Node_Assoc := Drivers_To_Template (CV.Nodes (Node_Name)
                                                    .Deployment_Node.Drivers)
                 & Assoc ("Partitions", Partitions)
                 & Assoc ("Partition_Names", Partition_Names)
                 & Assoc ("Has_Memory", Boolean'
                      (CV.Nodes (Node_Name).Deployment_Node.Memory.Name /= ""))
                 & Assoc ("VP_Names", VP_Names)
                 & Assoc ("VP_Package_Names", VP_Package_Names)
                 & Assoc ("VP_Platforms", VP_Platforms)
                 & Assoc ("VP_Classifiers", VP_Classifiers)
                 & Assoc ("Node_Name", Node_Name)
                 & Assoc ("CPU_Name",
                          CV.Nodes (Node_Name).Deployment_Node.CPU_Name)
                 & Assoc ("CPU_Family",
                          CV.Nodes (Node_Name).Deployment_Node.CPU_Family)
                 & Assoc ("CPU_Instance",
                          CV.Nodes (Node_Name).Deployment_Node.CPU_Instance)
                 & Assoc ("CPU_Platform",
                         CV.Nodes (Node_Name).Deployment_Node.CPU_Platform'Img)
                 & Assoc ("CPU_Classifier",
                          CV.Nodes (Node_Name).Deployment_Node.CPU_Classifier)
                 & Assoc ("Package_Name",
                          CV.Nodes (Node_Name).Deployment_Node.Package_Name)
                 & Assoc ("Ada_Runtime",
                          CV.Nodes (Node_Name).Deployment_Node.Ada_Runtime);
               Document_Template
                 (Templates_Concurrency_View_Sub_Node, Node_Assoc);
               return Parse (Path & "/node.tmplt", Node_Assoc);
            end Generate_Node;

            Nodes           : Unbounded_String;
            Tmpl_File       : constant String  := Path & "/filesys.tmplt";
            Tmpl_Sys        : constant String  := Path & "/system.tmplt";
            Valid_Dir       : constant Boolean := Exists (Tmpl_File);
            File_Sys        : constant String  :=
              (if Valid_Dir then Strip_String (Parse (Tmpl_File)) else "");
            Trig_Sys        : constant Boolean := Exists (Tmpl_Sys);
            Set_Sys         : Translate_Set;
            Node_Names,                    --  List of nodes
            Node_CPU,                      --  Corresponding CPU name
            Node_CPU_Cls,                  --  Corresponding CPU classifier
            Node_Major_Frame,              --  Corresponding time frame (TSP)
            Node_Has_Memory : Vector_Tag;  --  Corresponding memory flag (TSP)
            Partition_Names,               --  List of partitions
            Partition_Node,                --  Corresponding node name
            Partition_CPU,                 --  Corresponding CPU name
            Partition_Time,                --  Corresponding TSP VP time
            Partition_VP    : Vector_Tag;  --  for TSP: VP binding
            Part_Source_Name,
            Part_Source_Port,
            Part_Dest_Port,
            Part_Dest_Name  : Vector_Tag;  -- Inter-partition connections (TSP)
            Bus_Names,
            Bus_AADL_Pkg,
            Bus_Classifier  : Vector_Tag;  --  System busses
            Device_Node_Name,
            Device_Partition_Name : Vector_Tag;
            All_Drivers : Taste_Drivers.Vector;

            --  To keep a list of ASN.1 files/modules without duplicates:
            Unique_ASN1_Sorts_Set : String_Sets.Set;
            Unique_ASN1_Files,
            Unique_ASN1_Sorts,
            Unique_ASN1_Modules : Vector_Tag;
            Connect_From_Partition,           --  Partition to bus connections
            Connect_Port_Name,
            Connect_Via_Bus    : Vector_Tag;
            Found : Boolean := False;
         begin
            --  Prepare the template tags of system.aadl with the busses
            for Bus of CV.Deployment.Busses loop
               --  The bus user properties are ignored here
               --  Could be added if needed but they would require an
               --  additional template file to process the name/values.
               Bus_Names      := Bus_Names & Bus.Name;
               Bus_AADL_Pkg   := Bus_AADL_Pkg & Bus.AADL_Package;
               Bus_Classifier := Bus_Classifier & Bus.Classifier;
            end loop;

            --  Bus connections: we need the output port name, partition and
            --  bus name to make the AADL construct. Check Bus_Connection type
            --  in deployment_view.ads if anything else is needed. It does not
            --  directly provide the partition name of the function so we have
            --  to retrieve it here
            for BC : Bus_Connection of CV.Deployment.Connections loop
               Connect_Via_Bus   := Connect_Via_Bus   & BC.Bus_Name;
               Connect_Port_Name := Connect_Port_Name & BC.Source_Port;
               Found := False;
               for Node of CV.Deployment.Nodes loop
                  exit when Found;
                  for Part of Node.Partitions loop
                     exit when Found;
                     if Part.Bound_Functions.Contains
                       (To_String (BC.Source_Function))
                     then
                        Connect_From_Partition :=
                          Connect_From_Partition & Part.Name;
                        Found := True;
                     end if;
                  end loop;
               end loop;
               if not Found then
                  raise Concurrency_View_Error with
                    "Could not find partition of function "
                    & To_String (BC.Source_Function);
               end if;
            end loop;

            for Node in CV.Nodes.Iterate loop
               declare
                  Node_Name    : constant String := CV_Nodes.Key (Node);
                  Output_Dir   : constant String := CV_Out_Dir & Node_Name;
                  Do_It        : constant Boolean :=
                    Exists (Path & "/filenode.tmplt");
                  Filename_Set : constant Translate_Set :=
                    +Assoc ("Node_Name", Node_Name);
                  --  Get output file name from template
                  File_Name    : constant String :=
                    (if Do_It then
                        Strip_String
                       (Parse (Path & "/filenode.tmplt", Filename_Set))
                     else "");
                  --  Check if file already exists
                  Present      : constant Boolean :=
                    (File_Name /= ""
                     and then Exists (Output_Dir & "/" & File_Name));

                  Trig_Tmpl    : constant Translate_Set :=
                    CV.Configuration.To_Template
                    & Assoc ("Filename_Is_Present", Present)
                    & Assoc ("CPU_Name",
                             CV.Nodes (Node_Name).Deployment_Node.CPU_Name)
                    & Assoc ("CPU_Family",
                             CV.Nodes (Node_Name).Deployment_Node.CPU_Family)
                    & Assoc ("CPU_Platform",
                             CV.Nodes (Node_Name).Deployment_Node
                               .CPU_Platform'Img)
                    & Assoc ("CPU_Classifier",
                             CV.Nodes (Node_Name).Deployment_Node
                               .CPU_Classifier);

                  Trigger      : constant Boolean :=
                    (Node_Name /= "interfaceview"
                     and then Exists (Path & "/trigger.tmplt") and then
                     Strip_String
                       (Parse (Path & "/trigger.tmplt", Trig_Tmpl)) = "TRUE");
                  Node_Content : constant String :=
                    (if Trigger then Generate_Node (Node_Name)
                     else "");
               begin
                  Document_Template
                    (Templates_Concurrency_View_Sub_File_Node, Filename_Set);
                  Document_Template
                    (Templates_Concurrency_View_Sub_Trigger, Trig_Tmpl);
                  if Trigger then

                     --  Associate node name, CPU name and CPU classifier
                     --  Also set flag if a memory region is defined
                     --  (this is needed for AADL backends)
                     Node_Names := Node_Names & Node_Name;
                     Node_CPU := Node_CPU
                       & CV.Nodes (Node_Name).Deployment_Node.CPU_Name;
                     Node_CPU_Cls := Node_CPU_Cls
                       & CV.Nodes (Node_Name).Deployment_Node.CPU_Classifier;
                     Node_Has_Memory := Node_Has_Memory
                       & (CV.Nodes (Node_Name)
                          .Deployment_Node.Memory.Name /= "");
                     Node_Major_Frame := Node_Major_Frame
                       & CV.Nodes (Node_Name).Deployment_Node.CPU_Duration;

                     --  Associate partition name, corresponding node and CPU
                     --  for AADL backends
                     for Partition in CV.Nodes (Node_Name).Partitions.Iterate
                     loop
                        Partition_Names := Partition_Names
                          & CV_Partitions.Key (Partition);
                        Partition_CPU := Partition_CPU
                          & CV_Partitions.Element (Partition)
                          .Deployment_Partition.CPU_Name;
                        Partition_VP := Partition_VP
                          & CV_Partitions.Element (Partition)
                          .Deployment_Partition.VP_Name;
                        Partition_Node := Partition_Node & Node_Name;
                        Partition_Time := Partition_Time
                          & CV_Partitions.Element (Partition)
                          .Deployment_Partition.VP_Duration;

                        --  Create the inter-partition connections
                        for Out_Port of
                          CV_Partitions.Element (Partition).Out_Ports
                        loop
                           Part_Source_Name := Part_Source_Name
                             & CV_Partitions.Key (Partition);
                           Part_Source_Port := Part_Source_Port
                             & Out_Port.Port_Name;
                           Part_Dest_Name := Part_Dest_Name
                             & Out_Port.Remote_Partition_Name;
                           Part_Dest_Port := Part_Dest_Port
                             & Out_Port.Remote_Port_Name;
                        end loop;
                     end loop;

                     Nodes := Nodes & Newline & Node_Content;
                     if File_Name /= "" then
                        Create_Path (Output_Dir & Dir_Separator
                                       & Dir_Name (File_Name));
                        Create (File => Output_File,
                                Mode => Out_File,
                                Name => Output_Dir
                                  & Dir_Separator & File_Name);
                        Put_Line (Output_File, Node_Content);
                        Close (Output_File);
                     end if;
                  end if;
               end;
            end loop;
            --  Iterate again on the nodes to set the devices
            --  at system level (they could also be added to
            --  nodes if needed, but for the concurrency view
            --  in AADL they are only used at system level)
            for N : Taste_Node of CV.Deployment.Nodes loop
               --  Check that there if there are drivers, there is only one
               --  partition in the node as the current design does not specify
               --  what partition(s) use the drivers.
               if not N.Drivers.Is_Empty and N.Partitions.Length > 1 then
                  raise Concurrency_View_Error with
                    "Drivers in multi-partition systems are not supported";
               end if;

               All_Drivers.Append (N.Drivers);

               for D : Taste_Device_Driver of N.Drivers loop
                  Device_Node_Name  := Device_Node_Name & N.Name;
                  Device_Partition_Name :=  -- There must be only one
                    Device_Partition_Name & N.Partitions.First_Element.Name;
                  --  Update list of types and files without duplicates
                  if not Unique_ASN1_Sorts_Set.Contains
                    (Strip_String (To_String (D.ASN1_Typename)))
                  then
                     Unique_ASN1_Sorts_Set.Insert
                       (Strip_String (To_String (D.ASN1_Typename)));
                     Unique_ASN1_Sorts := Unique_ASN1_Sorts & D.ASN1_Typename;
                     Unique_ASN1_Modules :=
                       Unique_ASN1_Modules & D.ASN1_Module;
                     Unique_ASN1_Files := Unique_ASN1_Files & D.ASN1_Filename;
                  end if;
               end loop;
            end loop;

            if Trig_Sys and File_Sys /= "" and Nodes /= "" then
               --  Generate from system.tmplt
               Set_Sys := Join_Sets (CV.Configuration.To_Template,
                                     Drivers_To_Template (All_Drivers))
                 & Assoc ("Nodes",       Nodes)
                 & Assoc ("Node_Names",          Node_Names)
                 & Assoc ("Node_CPU",            Node_CPU)
                 & Assoc ("Node_CPU_Classifier", Node_CPU_Cls)
                 & Assoc ("Node_Major_Frame",    Node_Major_Frame)
                 & Assoc ("Node_Has_Memory",     Node_Has_Memory)
                 & Assoc ("Partition_Names",     Partition_Names)
                 & Assoc ("Partition_Node",      Partition_Node)
                 & Assoc ("Partition_CPU",       Partition_CPU)
                 & Assoc ("Partition_Duration",  Partition_Time)
                 & Assoc ("Partition_VP",        Partition_VP)
                 & Assoc ("Part_Source_Name",    Part_Source_Name)
                 & Assoc ("Part_Source_Port",    Part_Source_Port)
                 & Assoc ("Part_Dest_Name",      Part_Dest_Name)
                 & Assoc ("Part_Dest_Port",      Part_Dest_Port)
                 & Assoc ("Threads",             Threads)
                 & Assoc ("Thread_Names",        All_Thread_Names)
                 & Assoc ("Block_Names",         All_Block_Names)
                 & Assoc ("Target_Packages",     All_Target_Names)
                 & Assoc ("Bus_Names",           Bus_Names)
                 & Assoc ("Bus_AADL_Package",    Bus_AADL_Pkg)
                 & Assoc ("Bus_Classifier",      Bus_Classifier)
                 & Assoc ("Device_Node_Name",    Device_Node_Name)
                 & Assoc ("Device_Partition",    Device_Partition_Name)
                 & Assoc ("Unique_Dev_ASN1_Files", Unique_ASN1_Files)
                 & Assoc ("Unique_Dev_ASN1_Mod",   Unique_ASN1_Modules)
                 & Assoc ("Unique_Dev_ASN1_Sorts", Unique_ASN1_Sorts)
                 & Assoc ("Connect_From_Part",   Connect_From_Partition)
                 & Assoc ("Connect_Via_Bus",     Connect_Via_Bus)
                 & Assoc ("Connect_Port_Name",   Connect_Port_Name);
               Create_Path (CV_Out_Dir
                           & Dir_Separator & Dir_Name (File_Sys));
               Create (File => Output_File,
                       Mode => Out_File,
                       Name => CV_Out_Dir & Dir_Separator & File_Sys);
               Put_Line (Output_File, Parse (Tmpl_Sys, Set_Sys));
               Document_Template
                 (Templates_Concurrency_View_Sub_System, Set_Sys);
               Close (Output_File);
            end if;
         end;
         <<continue>>
      end loop;
      End_Search (ST);
   end Generate_Code;

   procedure Generate_CV (CV : Taste_Concurrency_View) is
   begin
      CV.Generate_Code;
   exception
      when Error : Concurrency_View_Error | Ada.IO_Exceptions.Name_Error =>
         Put_Error ("Concurrency View : "
                    & Ada.Exceptions.Exception_Message (Error));
         raise Quit_Taste;
   end Generate_CV;

end TASTE.Concurrency_View;
