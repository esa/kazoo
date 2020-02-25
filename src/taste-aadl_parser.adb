--  ************************ TASTE AADL Parser **************************  --
--  Based on Ocarina ****************************************************  --
--  (c) 2019 Maxime Perrotin / European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

with System.Assertions,
     Ada.Exceptions,
     Ada.Text_IO,
     Ada.Directories,
     Ada.Strings.Equal_Case_Insensitive,
     Ada.Containers,
     Ada.Characters.Handling,   -- Contains "To_Lower"
     GNAT.Command_Line,
     Errors,
     Locations,
     Ocarina.AADL_Values,
     Ocarina.Namet,
     Ocarina.Configuration,
     Ocarina.Files,
     Ocarina.Parser,
     Ocarina.FE_AADL.Parser,
     TASTE.Backend,
     TASTE.Backend.Build_Script,
     TASTE.Backend.Code_Generators,
     TASTE.Semantic_Check;

use Ada.Text_IO,
    Ada.Exceptions,
    Ada.Directories,
    Ada.Containers,
    Ada.Characters.Handling,
    Locations,
    Ocarina.Namet,
    Ocarina;

--  for the parsing of ConcurrencyView_Properties.aadl:
--  with ocarina.BE_AADL; use ocarina.BE_AADL;
with Ocarina.ME_AADL.AADL_Tree.Nodes;
with Ocarina.ME_AADL.AADL_Tree.Nutils;
use Ocarina.ME_AADL.AADL_Tree.Nodes;
use Ocarina.ME_AADL.AADL_Tree.Nutils;

package body TASTE.AADL_Parser is

   function Initialize return Taste_Configuration is
      File_Name  : Name_Id;
      File_Descr : Location;
      Cfg        : Taste_Configuration;
      use String_Holders;
   begin
      Banner;
      --  Parse arguments before initializing Ocarina, otherwise Ocarina eats
      --  some arguments (all file parameters).
      Parse_Command_Line (Cfg);
      Initialize_Ocarina;

      AADL_Language := Get_String_Name ("aadl");

      if Cfg.Interface_View.Is_Empty and not Cfg.Check_Data_View then
         --  Use "InterfaceView.aadl" by default, if nothing else is specified
         --  and if the tool is not only called to check the data view
         --  Cfg.Interface_View := Default_Interface_View'Access;
         Cfg.Interface_View := To_Holder (Default_Interface_View);
      end if;

      --  An interface view is expected, look for it and parse it
      if not Cfg.Interface_View.Is_Empty then
         Set_Str_To_Name_Buffer (Cfg.Interface_View.Element);

         File_Name := Ocarina.Files.Search_File (Name_Find);
         if File_Name = No_Name then
            raise AADL_Parser_Error
              with "Interface View file not found : "
              & Cfg.Interface_View.Element;
         end if;

         File_Descr := Ocarina.Files.Load_File (File_Name);

         Interface_Root := Ocarina.Parser.Parse
           (AADL_Language, Interface_Root, File_Descr);

         --  Parse TASTE_IV_Properties.aadl
         Set_Str_To_Name_Buffer ("TASTE_IV_Properties.aadl");
         File_Name  := Ocarina.Files.Search_File (Name_Find);
         File_Descr := Ocarina.Files.Load_File (File_Name);
         Interface_Root := Ocarina.Parser.Parse (AADL_Language,
                                                 Interface_Root, File_Descr);

         if Interface_Root = No_Node then
            raise AADL_Parser_Error with "Interface view is incorrect";
         end if;
      end if;

      if Cfg.Glue then
         --  Look for a deployment view (or DeploymentView.aadl by default)
         --  if the glue generation is requested. Not needed for skeletons.
         if Cfg.Deployment_View.Is_Empty then
            Cfg.Deployment_View := To_Holder (Default_Deployment_View);
         end if;

         Set_Str_To_Name_Buffer (Cfg.Deployment_View.Element);

         File_Name := Ocarina.Files.Search_File (Name_Find);
         if File_Name = No_Name then
            raise AADL_Parser_Error
              with "Deployment View file not found : "
              & Cfg.Deployment_View.Element;
         end if;

         File_Descr := Ocarina.Files.Load_File (File_Name);
         Deployment_Root := Ocarina.Parser.Parse
           (AADL_Language, Deployment_Root, File_Descr);

         if Deployment_Root = No_Node then
            raise AADL_Parser_Error with "Deployment View is incorrect";
         end if;
      end if;

      for Each of Cfg.Other_Files loop
         --  Add other files to the Interface and (if any) deployment roots
         --  (List of files specified in the command line)
         Set_Str_To_Name_Buffer (Each);
         File_Name := Ocarina.Files.Search_File (Name_Find);
         if File_Name = No_Name then
            raise AADL_Parser_Error with "File not found: " & Each;
         end if;
         File_Descr := Ocarina.Files.Load_File (File_Name);

         Interface_Root := Ocarina.Parser.Parse
           (AADL_Language, Interface_Root, File_Descr);
         if Deployment_Root /= No_Node then
            Deployment_Root := Ocarina.Parser.Parse
              (AADL_Language, Deployment_Root, File_Descr);
         end if;
      end loop;

      if not Cfg.Data_View.Is_Empty then
         Set_Str_To_Name_Buffer (Cfg.Data_View.Element);
         File_Name := Ocarina.Files.Search_File (Name_Find);
         if File_Name = No_Name then
            raise AADL_Parser_Error
              with "Could not find " & Cfg.Data_View.Element;
         end if;
      else
         --  Try with default name (DataView.aadl)
         Set_Str_To_Name_Buffer (Default_Data_View);
         File_Name := Ocarina.Files.Search_File (Name_Find);
         if File_Name /= No_Name then
            Cfg.Data_View := To_Holder (Default_Data_View);
         elsif Cfg.Check_Data_View then
            --  No dataview found, while user asked explicitly for a check
            raise AADL_Parser_Error with "Could not find DataView.aadl";
         end if;
      end if;

      if File_Name /= No_Name then
         Put_Info ("Parsing " & Cfg.Data_View.Element);

         File_Descr := Ocarina.Files.Load_File (File_Name);

         --  Add the Data View to the Interface View root, if any
         if Interface_Root /= No_Node then
            Interface_Root := Ocarina.Parser.Parse
              (AADL_Language, Interface_Root, File_Descr);
         end if;

         --  Add the Data View to the Deployment View root, if any
         if Deployment_Root /= No_Node then
            Deployment_Root := Ocarina.Parser.Parse
               (AADL_Language, Deployment_Root, File_Descr);
         end if;
         --  Also parse the data view as a root component
         Ocarina.FE_AADL.Parser.Add_Pre_Prop_Sets := False;
         Dataview_root := Ocarina.Parser.Parse
                            (AADL_Language, Dataview_root, File_Descr);
      end if;

      --  If present, try and parse ConcurrencyView_Properties.aadl
      Set_Str_To_Name_Buffer ("ConcurrencyView_Properties.aadl");
      File_Name := Ocarina.Files.Search_File (Name_Find);
      if File_Name = No_Name then
         Put_Debug ("No ConcurrencyView_Properties.aadl file found");
      else
         Put_Info ("Parsing ConcurrencyView_Properties.aadl");
         File_Descr := Ocarina.Files.Load_File (File_Name);

         Concurrency_Properties_Root := Ocarina.Parser.Parse
           (AADL_Language, Concurrency_Properties_Root, File_Descr);
         if Concurrency_Properties_Root = No_Node then
            raise AADL_Parser_Error with
              "Error parsing ConcurrencyView_Properties.aadl";
         end if;
      end if;
      return Cfg;
   end Initialize;

   function Parse_Project return TASTE_Model is
      Result : TASTE_Model;
      use Deployment_View_Holders;
   begin
      Result.Configuration := Initialize;

      if Interface_Root /= No_Node then
         --  Parse Interface and Deployment View
         begin
            Result.Interface_View := Parse_Interface_View (Interface_Root);
         exception
            when System.Assertions.Assert_Failure =>
               raise AADL_Parser_Error with "Interface view parsing error";
         end;

         if not Result.Configuration.No_Stdlib then
            AADL_Lib.Append ("ocarina_components.aadl");
         end if;

         if Deployment_Root /= No_Node
           and not Result.Configuration.Deployment_View.Is_Empty
         then
            AADL_Lib.Append (Result.Configuration.Interface_View.Element);
            Result.Deployment_View :=
              To_Holder (Parse_Deployment_View
                         (Deployment_Root, Result.Interface_View));
         end if;
      end if;

      if not Result.Configuration.Data_View.Is_Empty then
         begin
            Result.Data_View := Parse_Data_View (Dataview_root);
            Result.Data_View.Check_Files;
         exception
            when Constraint_Error =>
               raise Data_View_Error with "Update your data view!";
         end;
      end if;

      Ocarina.Configuration.Reset_Modules;
      --  Ocarina.Reset;  (No: This make the CV_Properties analysis fail)

      if Result.Configuration.Check_Data_View then
         raise Quit_Taste;
      end if;

      Semantic_Check.Check_Model (Result);
      return Result;
   exception
      when Error : AADL_Parser_Error
         | Interface_Error
         | Function_Error
         | No_RCM_Error
         | Deployment_View_Error
         | Data_View_Error
         | Semantic_Check.Semantic_Error
         | Device_Driver_Error =>
         Put_Error (Exception_Message (Error));
         raise Quit_Taste;
      when GNAT.Command_Line.Exit_From_Command_Line =>
         New_Line;
         Put_Info ("For more information, visit " & Underline & White_Bold
                   & "https://taste.tools");
         raise Quit_Taste;
      when GNAT.Command_Line.Invalid_Switch
         | GNAT.Command_Line.Invalid_Parameter
         | GNAT.Command_Line.Invalid_Section =>
         Put_Error ("Invalid switch or parameter (try --help)" & No_Color);
         raise Quit_Taste;
      when Quit_Taste =>
         raise;
      when E : others =>
         Errors.Display_Bug_Box (E);
         raise Quit_Taste;
   end Parse_Project;

   function Find_Binding (Model : TASTE_Model;
                          F     : Unbounded_String)
                          return Option_Partition.Option is
      use Option_Partition;
      function Is_Equal (Left, Right : String) return Boolean
         renames Ada.Strings.Equal_Case_Insensitive;
      Function_Name : constant String := To_String (F);
   begin
      for Node of Model.Deployment_View.Element.Nodes loop
         for Each of Node.Partitions loop
            for Binding of Each.Bound_Functions loop
               if Is_Equal (Binding, Function_Name) then
                  return Just (Each);
               end if;
            end loop;
         end loop;
      end loop;
      return Nothing;
   end Find_Binding;

   procedure Set_Calling_Threads (Partition : in out CV_Partition) is
      procedure Rec_Add_Calling_Thread (Thread_Id : String;
                                        Block_Id  : String) is
      begin
         --  First add thread to its corresponding protected function
         --  Stop recursion if thread is already there...
         if not String_Sets.To_Set (Thread_Id).Is_Subset
           (Of_Set => Partition.Blocks (Block_Id).Calling_Threads)
         then
            Partition.Blocks (Block_Id).Calling_Threads.Insert (Thread_Id);
         else
            return;
         end if;

         --  Then recurse on its (Un)protected RIs.
         for RI of Partition.Blocks (Block_Id).Ref_Function.Required loop
            if RI.RCM = Protected_Operation or RI.RCM = Unprotected_Operation
            then
               for Remote of RI.Remote_Interfaces loop
                  Rec_Add_Calling_Thread
                    (Thread_Id => Thread_Id,
                     Block_Id  => To_String (Remote.Function_Name));
               end loop;
            end if;
         end loop;
      end Rec_Add_Calling_Thread;
   begin
      for Each of Partition.Threads loop
         Rec_Add_Calling_Thread (Thread_Id => To_String (Each.Name),
                                 Block_Id  => To_String
                                   (Each.Protected_Block_Name));
      end loop;
   end Set_Calling_Threads;

   --  Find the output ports of a thread by following the connections
   function Get_Output_Ports (Model : TASTE_Model;
                              F     : Taste_Terminal_Function) return Ports.Map
   is
      Result            : Ports.Map;
      Visited_Functions : String_Sets.Set;

      procedure Rec_Find_Thread (Ports_Map  : in out Ports.Map;
                                 Visited    : in out String_Sets.Set;
                                 Func       : Taste_Terminal_Function) is
         use String_Sets;
         Current_Function : constant String_Sets.Set :=
           String_Sets.To_Set (To_String (Func.Name));
      begin
         --  Recursively find distand threads by following (un)pro RI paths
         --  Ignore already visited nodes (system may have circular paths)
         if Current_Function.Is_Subset (Of_Set => Visited) then
            return;
         else
            Visited := Visited or Current_Function;
         end if;
         if Func.Is_Type then
            --  Ignore function types, only work with instances
            return;
         end if;

         for RI of Func.Required loop
            if RI.Remote_Interfaces.Is_Empty then
               goto Continue;
            end if;

            if RI.RCM = Unprotected_Operation or RI.RCM = Protected_Operation
            then
               Rec_Find_Thread (Ports_Map => Ports_Map,
                                Visited   => Visited,
                                Func      =>
                                  Model.Interface_View.Flat_Functions
                                  (To_String
                          (RI.Remote_Interfaces.First_Element.Function_Name)));
            else
               declare
                  --  Assume only one remote connection per RI
                  --  Have to iterate on Remote_Interfaces if that changes

                  Dist      : constant Remote_Entity :=
                    RI.Remote_Interfaces.First_Element;
                  Remote_Thread_Name : constant Unbounded_String :=
                    To_Lower (To_String (Dist.Function_Name))
                    & "_" & Dist.Interface_Name;
                  Port_Name : constant Unbounded_String := RI.Name;
                  New_P     : constant Thread_Port :=
                    (Name          => Port_Name,
                     Remote_Thread => Remote_Thread_Name,
                     Remote_PI     => Dist.Interface_Name,
                     RI            => RI);
               begin
                  Ports_Map.Include (Key      => To_String (Port_Name),
                                     New_Item => New_P);
               end;
            end if;
            <<Continue>>
         end loop;
      end Rec_Find_Thread;
   begin
      Rec_Find_Thread (Ports_Map => Result,
                       Visited   => Visited_Functions,
                       Func      => F);
      return Result;
   end Get_Output_Ports;

   procedure Add_Concurrency_View (Model : in out TASTE_Model) is
      CV : Taste_Concurrency_View :=
        (Base_Template_Path => Model.Configuration.Binary_Path,
         Base_Output_Path   => Model.Configuration.Output_Dir,
         Deployment         => Model.Deployment_View.Element,
         Configuration      => Model.Configuration,
         others             => <>);
      use String_Vectors;
   begin
      --  Initialize the lists of nodes and partitions based on the DV
      for Node of Model.Deployment_View.Element.Nodes loop
         declare
            New_Node : CV_Node :=
              (Deployment_Node => Node, others => <>);
         begin
            for Partition of Node.Partitions loop
               declare
                  New_Partition : constant CV_Partition :=
                    (Deployment_Partition => Partition, others => <>);
               begin
                  New_Node.Partitions.Insert
                    (Key      => To_String (Partition.Name),
                     New_Item => New_Partition);
               end;
            end loop;
            CV.Nodes.Insert (Key      => To_String (Node.Name),
                             New_Item => New_Node);
         end;
      end loop;

      --  Create one thread per Cyclic and Sporadic interface
      --  Create one protected block per application code
      --  and map them on the Concurrency View nodes/partitions
      for F of Model.Interface_View.Flat_Functions loop
         if F.Is_Type then
            goto Continue;
         end if;
         declare
            Function_Name : constant String := To_String (F.Name);
            Node : constant Option_Node.Option :=
              Model.Deployment_View.Element.Find_Node (Function_Name);
            Node_Name : constant String :=
              (if Node.Has_Value
               then To_String (Node.Unsafe_Just.Name)
               else "");
            Partition_Name : constant String :=
              (if Node.Has_Value
               then To_String (Node.Unsafe_Just.Find_Partition
                 (Function_Name).Unsafe_Just.Name)
               else "");

            Block : Protected_Block :=
              (Ref_Function => F,
               Node         => Node,
               others       => <>);
         begin
            if not Node.Has_Value then
               --  Ignore functions that are not mapped to a node/partition
               goto Continue;
            end if;

            for PI of F.Provided loop
               --  Ignore interfaces that are not called by anyone
               if PI.RCM /= Cyclic_Operation
                 and PI.Remote_Interfaces.Length = 0
               then
                  Put_Info ("Ignoring unconnected interface "
                            & To_String (PI.Name) & " in function "
                            & To_String (F.Name));
                  goto next_pi;
               end if;

               declare
                  New_PI : Protected_Block_PI := (Name   => PI.Name,
                                                  PI     => PI,
                                                  others => <>);
               begin
                  --  Convert cyclic/sporadic to Protected
                  New_PI.PI.RCM := (if PI.RCM = Unprotected_Operation
                                    then Unprotected_Operation
                                    else Protected_Operation);
                  --  Check in the DV if any caller is remote
                  for Remote of PI.Remote_Interfaces loop
                     declare
                        Remote_Node : constant Option_Node.Option :=
                          Model.Deployment_View.Element.Find_Node
                            (To_String (Remote.Function_Name));
                     begin
                        if not Remote_Node.Has_Value
                          or not Block.Node.Has_Value
                        then
                           raise Concurrency_View_Error with
                             "Concurrency Generation Error (parser bug?)";
                        end if;

                        if Block.Node.Unsafe_Just /= Remote_Node.Unsafe_Just
                        then
                           --  At least one caller is on a different node
                           New_PI.Local_Caller := False;
                        end if;
                     end;
                  end loop;
                  Block.Block_Provided.Insert (Key      => To_String (PI.Name),
                                               New_Item => New_PI);
               end;
               if PI.RCM = Cyclic_Operation or PI.RCM = Sporadic_Operation then
                  declare
                     Thread : constant AADL_Thread :=
                       (Name                 => To_Lower (To_String (F.Name))
                        & "_" & PI.Name,
                        Partition_Name       => US (Partition_Name),
                        RCM                  => US (PI.RCM'Img),
                        Need_Mutex           => (F.Provided.Length > 1),
                        Entry_Port_Name      => PI.Name,
                        Protected_Block_name => Block.Ref_Function.Name,
                        Node                 => Block.Node,
                        PI                   => PI,
                        Output_Ports         => Get_Output_Ports (Model, F),
                        Priority             => US ("1"),
                        Dispatch_Offset_Ms   => US ("0"),
                        Stack_Size_In_Bytes  => US ("50000"));
                  begin
                     CV.Nodes
                       (Node_Name).Partitions (Partition_Name).Threads.Include
                       (Key      => To_String (Thread.Name),
                        New_Item => Thread);
                  end;
               end if;
               <<next_pi>>
            end loop;
            --  Add the block to the Concurrency View
            CV.Nodes (Node_Name).Partitions (Partition_Name).Blocks.Insert
              (Key      => To_String (Block.Ref_Function.Name),
               New_Item => Block);
         end;
         <<Continue>>
      end loop;

      for Node of CV.Nodes loop
         for Partition of Node.Partitions loop
            --  Find and set protected blocks calling threads
            Set_Calling_Threads (Partition);

            --  Check that all blocks have a calling thread, otherwise
            --  they will never run
            for B of Partition.Blocks loop
               if B.Calling_Threads.Length = 0 then
                  raise Concurrency_View_Error with
                    "Function "
                    & To_String (B.Ref_Function.Name)
                    & " has no active caller";
               end if;
            end loop;

            --  Define ports at partition (process) level
            --  (ports are for all interfaces of a function not located
            --  in the same partition of the system)
            for T of Partition.Threads loop
               --  Check each Remote PI of the entry port of the thread
               for Remote of T.PI.Remote_Interfaces loop
                  declare
                     Node : constant Option_Node.Option  :=
                       CV.Deployment.Find_Node
                         (To_String (Remote.Function_Name));
                     Part : Option_Partition.Option;
                     --  Optional type of the parameter:
                     Sort : constant Unbounded_String :=
                       (if not T.PI.Params.Is_Empty
                        then T.PI.Params.First_Element.Sort
                        else US (""));
                  begin
                     if Node.Has_Value then
                        Part :=
                          Node.Unsafe_Just.Find_Partition
                            (To_String (Remote.Function_Name));

                        if Part.Has_Value
                          and then Part.Unsafe_Just.Name
                            /= Partition.Deployment_Partition.Name
                             and then not Partition.In_Ports.Contains
                               (To_String (T.Entry_Port_Name))
                        then
                           --  shouldn't we check for presence first in case
                           --  there are multiple callers?
                           Partition.In_Ports.Insert
                             (Key      => To_String (T.Entry_Port_Name),
                              New_Item => (Port_Name   => T.Entry_Port_Name,
                                           Thread_Name => T.Name,
                                           Type_Name   => Sort,
                                           Remote_Partition_Name
                                                    => Part.Unsafe_Just.Name));
                        end if;
                     else
                        Put_Error ("This should never happen.");
                     end if;
                  end;
               end loop;
               --  Do the same for output ports
               for Out_Port of T.Output_Ports loop
                  for Remote of Out_Port.RI.Remote_Interfaces loop
                     declare
                        Node : constant Option_Node.Option  :=
                          CV.Deployment.Find_Node
                            (To_String (Remote.Function_Name));
                        Part : Option_Partition.Option;
                        --  Optional type of the parameter:
                        Sort : constant Unbounded_String :=
                          (if not Out_Port.RI.Params.Is_Empty
                           then Out_Port.RI.Params.First_Element.Sort
                           else US (""));
                     begin
                        if Node.Has_Value then
                           Part := Node.Unsafe_Just.Find_Partition
                             (To_String (Remote.Function_Name));

                           if Part.Has_Value and then Part.Unsafe_Just.Name
                             /= Partition.Deployment_Partition.Name
                           then
                              if not Partition.Out_Ports.Contains
                                (To_String (Out_Port.RI.Name))
                              then
                                 --  Create a new port and reference the thread
                                 Partition.Out_Ports.Insert
                                   (Key      => To_String (Out_Port.RI.Name),
                                    New_Item => (Port_Name   =>
                                                     Out_Port.RI.Name,
                                                 Connected_Threads =>
                                                   String_Vectors.Empty_Vector
                                                 & To_String (T.Name),
                                                 Type_Name   => Sort,
                                                 Remote_Partition_Name =>
                                                   Part.Unsafe_Just.Name,
                                                 Remote_Port_Name =>
                                                   Remote.Interface_Name));
                              else
                                 --  Port already exists: just add this thread
                                 Partition.Out_Ports
                                   (To_String
                                      (Out_Port.RI.Name)).Connected_Threads
                                     .Append (To_String (T.Name));
                              end if;
                           end if;
                        else
                           Put_Error ("This should never happen.");
                        end if;
                     end;
                  end loop;
               end loop;
            end loop;
         end loop;
      end loop;

      Model.Concurrency_View := CV;
   end Add_Concurrency_View;

   procedure Dump (Model : TASTE_Model) is
      Output_Path : constant String :=
        Model.Configuration.Output_Dir.Element & "/Debug";
      Output  : File_Type;
   begin
      if Model.Configuration.Debug_Flag then
         Create_Path (Output_Path);
         Create (File => Output,
                 Mode => Out_File,
                 Name => Output_Path & "/InterfaceView.dump");
         Put_Info ("Dump of the Interface View");
         Model.Interface_View.Debug_Dump (Output);
         Close (Output);

         if not Model.Configuration.Deployment_View.Is_Empty then
            Create (File => Output,
                    Mode => Out_File,
                    Name => Output_Path & "/DeploymentView.dump");
            Put_Info ("Dump of the Deployment View");
            Model.Deployment_View.Element.Debug_Dump (Output);
            Close (Output);
         end if;

         if Model.Configuration.Glue then
            Create (File => Output,
                    Mode => Out_File,
                    Name => Output_Path & "/ConcurrencyView.dump");
            Put_Info ("Dump of the Concurrency View");
            Model.Concurrency_View.Debug_Dump (Output);
            Close (Output);
         end if;

         Create (File => Output,
                 Mode => Out_File,
                 Name => Output_Path & "/DataView.dump");
         Put_Info ("Dump of the Data View");
         Model.Data_View.Debug_Dump (Output);
         Close (Output);

         Create (File => Output,
                 Mode => Out_File,
                 Name => Output_Path & "/commandline.dump");
         Put_Info ("Dump of the Command Line");
         Model.Configuration.Debug_Dump (Output);
         Close (Output);

         Put_Info ("Make a local copy of ASN.1 files for export");
         Create_Path (Output_Path & "/Export");
         Model.Data_View.Export_ASN1_Files (Output_Path & "/Export/");
      end if;
   exception
      when Error : others =>
         Put_Error ("Debug Dump : " & Exception_Message (Error));
         raise Quit_Taste;
   end Dump;

   procedure Generate_Build_Script (Model : TASTE_Model) is
   begin
      TASTE.Backend.Build_Script.Generate (Model);
   end Generate_Build_Script;

   procedure Generate_Code (Model : TASTE_Model) is
   begin
      TASTE.Backend.Code_Generators.Generate (Model);
   exception
      when Error : TASTE.Backend.Code_Generators.ACG_Error =>
         Put_Error (Exception_Message (Error));
         raise Quit_Taste;
      when Error : others =>
         Errors.Display_Bug_Box (Error);
         raise Quit_Taste;
   end Generate_Code;

   function Process_Function (F : in out Taste_Terminal_Function)
      return Function_Maps.Map
   is
      New_Functions    : Function_Maps.Map;
   begin
      --  Look for GUIs and add a Poll PI (if there is at least one RI)
      if F.Required.Length > 0 and F.Language = "gui" then
         F.Provided.Insert (Key      => "Poll",
                            New_Item => (Name            => US ("Poll"),
                                         Parent_Function => F.Name,
                                         RCM             => Cyclic_Operation,
                                         Period_Or_MIAT  => 10,
                                         others => <>));
      end if;
      return New_Functions;
   end Process_Function;

   procedure Preprocessing (Model : in out TASTE_Model) is
      New_Functions : Function_Maps.Map;
      DV : Complete_Deployment_View := Model.Deployment_View.Element;
      use Remote_Entities,
          Parameters;
   begin
      --  Processing of user-defined functions (may return a list of new
      --  functions that will be added to the model)
      for F of Model.Interface_View.Flat_Functions loop
         declare
            Funcs : constant Function_Maps.Map := Process_Function (F);
         begin
            for Each of Funcs loop
               New_Functions.Insert (Key      => To_String (Each.Name),
                                     New_Item => Each);
            end loop;
         end;
      end loop;

      --  For each partition generate a timer manager if needed
      for Node : Taste_Node of DV.Nodes loop
         for Partition : Taste_Partition of Node.Partitions loop
            declare
               Manager_Name  : constant String :=
                 To_String (Partition.Name) & "_Timer_Manager";
               Tick_PI       : constant Taste_Interface :=
                 (Name            => US ("Tick"),
                  Parent_Function => US (Manager_Name),
                  Language        => US ("Timer_Manager"),

                  RCM             => Cyclic_Operation,
                  Period_Or_MIAT  => 10,   --  Configurable parameter?
                  others          => <>);
               Timer_Manager : Taste_Terminal_Function :=
                 (Name     => US (Manager_Name),
                  Language => US ("Timer_Manager"),
                  others   => <>);
               Need_Timer_Manager : Boolean := False;
            begin
               Timer_Manager.Provided.Insert (Key      => Manager_Name,
                                              New_Item => Tick_PI);
               for Function_Name : String of Partition.Bound_Functions loop
                  for Timer_Name : String of
                    Model.Interface_View.Flat_Functions (Function_Name).Timers
                  loop
                     Need_Timer_Manager := True;
                     declare
                        Func_Language   : constant String :=
                          TASTE.Backend.Language_Spelling
                            (Model.Interface_View.Flat_Functions
                               (Function_Name));
                        Name_In_Manager : constant String :=
                          Function_Name & "_" & Timer_Name;

                        Manager_As_Remote : constant Remote_Entity :=
                          (Function_Name  => Timer_Manager.Name,
                           Language       => US ("C"),
                           Interface_Name => US (Name_In_Manager));

                        Function_As_Remote : constant Remote_Entity :=
                          (Function_Name  => US (Function_Name),
                           Language       => US (Func_Language),
                           Interface_Name => US (Timer_Name));

                        Timer_PI : constant Taste_Interface :=
                          (Name              => US (Timer_Name),
                           Parent_Function   => US (Function_Name),
                           Language          =>
                             Model.Interface_View.Flat_Functions
                               (Function_Name).Language,
                           Remote_Interfaces =>
                             Remote_Entities.Empty_Vector & Manager_As_Remote,
                           Params            => Parameters.Empty_Vector,
                           RCM               => Sporadic_Operation,
                           Period_Or_Miat    => 1,
                           Is_Timer          => True,
                           others            => <>);

                        Timer_RI : constant Taste_Interface :=
                          (Name              => US (Name_In_Manager),
                           Parent_Function   => US (Manager_Name),
                           Language          => US ("Timer_Manager"),
                           Remote_Interfaces =>
                             Remote_Entities.Empty_Vector & Function_As_Remote,
                           Params            => Parameters.Empty_Vector,
                           RCM               => Sporadic_Operation,
                           Period_Or_Miat    => 1,
                           others            => <>);

                        --  Define protected functions to SET/RESET the timer
                        Set_Name_In_Manager : constant String :=
                          "SET_" & Function_Name & "_" & Timer_Name;

                        Reset_Name_In_Manager : constant String :=
                          "RESET_" & Function_Name & "_" & Timer_Name;

                        Set_Name_In_Function : constant String :=
                          "SET_" & Timer_Name;

                        Reset_Name_In_Function : constant String :=
                          "RESET_" & Timer_Name;

                        Set_PI_In_Manager : constant Taste_Interface :=
                          (Name              => US (Set_Name_In_Manager),
                           Parent_Function   => US (Manager_Name),
                           Language          => US ("Timer_Manager"),
                           Remote_Interfaces => Remote_Entities.Empty_Vector &
                           (Function_Name  => US (Function_Name),
                            Language       => US (Func_Language),
                            Interface_Name => US (Set_Name_In_Function)),
                           Params            => Parameters.Empty_Vector &
                           (Name            => US ("Val"),
                            Sort            => US ("T_UInt32"),
                            ASN1_Basic_Type => ASN1_Integer,
                            ASN1_Module     => US ("TASTE_BasicTypes"),
                            ASN1_File_Name  => US ("taste-types.asn"),
                            Encoding        => Native,
                            Direction       => Param_In),
                           RCM               => Protected_Operation,
                           Period_Or_Miat    => 1,
                           others            => <>);

                        Reset_PI_In_Manager : constant Taste_Interface :=
                          (Name              => US (Reset_Name_In_Manager),
                           Parent_Function   => US (Manager_Name),
                           Language          => US ("Timer_Manager"),
                           Remote_Interfaces => Remote_Entities.Empty_Vector &
                           (Function_Name  => US (Function_Name),
                            Language       => US (Func_Language),
                            Interface_Name => US (Reset_Name_In_Function)),
                           Params            => Parameters.Empty_Vector,
                           RCM               => Protected_Operation,
                           Period_Or_Miat    => 1,
                           others            => <>);

                        Set_RI_In_Function : constant Taste_Interface :=
                          (Name              => US (Set_Name_In_Function),
                           Parent_Function   => US (Function_Name),
                           Language          =>
                             Model.Interface_View.Flat_Functions
                               (Function_Name).Language,
                           Remote_Interfaces => Remote_Entities.Empty_Vector &
                           (Function_Name  => US (Manager_Name),
                            Language       => US ("C"),  --  manager is in C
                            Interface_Name => US (Set_Name_In_Manager)),
                           Params            => Parameters.Empty_Vector &
                           (Name           => US ("Val"),
                            Sort           => US ("T_UInt32"),
                            ASN1_Basic_Type => ASN1_Integer,
                            ASN1_Module    => US ("TASTE_BasicTypes"),
                            ASN1_File_Name => US ("taste-types.asn"),
                            Encoding       => Native,
                            Direction      => Param_In),
                           RCM               => Protected_Operation,
                           Is_Timer          => True,
                           Period_Or_Miat    => 1,
                           others            => <>);

                        Reset_RI_In_Function : constant Taste_Interface :=
                          (Name              => US (Reset_Name_In_Function),
                           Parent_Function   => US (Function_Name),
                           Language          =>
                             Model.Interface_View.Flat_Functions
                               (Function_Name).Language,
                           Remote_Interfaces => Remote_Entities.Empty_Vector &
                           (Function_Name  => US (Manager_Name),
                            Language       => US ("C"),  -- manager is in C
                            Interface_Name => US (Reset_Name_In_Manager)),
                           Params            => Parameters.Empty_Vector,
                           RCM               => Protected_Operation,
                           Period_Or_Miat    => 1,
                           Is_Timer          => True,
                           others            => <>);

                        --  Create the connections in the interface view
                        Conn_Expire : constant Connection :=
                          (Caller   => US (Manager_Name),
                           Callee   => US (Function_Name),
                           RI_Name  => US (Name_In_Manager),
                           PI_Name  => US (Timer_Name),
                           Channels => String_Vectors.Empty_Vector);

                        Conn_Set : constant Connection :=
                          (Caller   => US (Function_Name),
                           Callee   => US (Manager_Name),
                           RI_Name  => US (Set_Name_In_Function),
                           PI_Name  => US (Set_Name_In_Manager),
                           Channels => String_Vectors.Empty_Vector);

                        Conn_Reset : constant Connection :=
                          (Caller   => US (Function_Name),
                           Callee   => US (Manager_Name),
                           RI_Name  => US (Reset_Name_In_Function),
                           PI_Name  => US (Reset_Name_In_Manager),
                           Channels => String_Vectors.Empty_Vector);
                     begin
                        --  Add timer expiration sporadic PI to the function
                        --  (modify the interface view in place)
                        Model.Interface_View.Flat_Functions (Function_Name)
                          .Provided.Insert (Key      => Timer_Name,
                                            New_Item => Timer_PI);

                        --  Add corresponding RI in the timer manager
                        Timer_Manager.Required.Insert (Key => Name_In_Manager,
                                                       New_Item => Timer_RI);

                        --  Add Set/Reset required interfaces to the function
                        Model.Interface_View.Flat_Functions (Function_Name)
                          .Required.Insert (Key      => Set_Name_In_Function,
                                            New_Item => Set_RI_In_Function);

                        Model.Interface_View.Flat_Functions (Function_Name)
                          .Required.Insert (Key      => Reset_Name_In_Function,
                                            New_Item => Reset_RI_In_Function);

                        --  Add corresponding Set/Reset PIs in the manager
                        Timer_Manager.Provided.Insert
                          (Key      => Set_Name_In_Manager,
                           New_Item => Set_PI_In_Manager);

                        Timer_Manager.Provided.Insert
                          (Key      => Reset_Name_In_Manager,
                           New_Item => Reset_PI_In_Manager);

                        Model.Interface_View.Connections.Append (Conn_Expire);
                        Model.Interface_View.Connections.Append (Conn_Set);
                        Model.Interface_View.Connections.Append (Conn_Reset);

                        --  Add timer to the list of timers in the manager
                        Timer_Manager.Timers.Append
                          (Function_Name & "_" & Timer_Name);
                     end;
                  end loop;
               end loop;

               if Need_Timer_Manager then
                  --  Add the timer manager to the interface view
                  Model.Interface_View.Flat_Functions.Insert
                    (Key      => Manager_Name,
                     New_Item => Timer_Manager);
                  --  Bind it in the deployment view
                  Partition.Bound_Functions.Insert (Manager_Name);
               end if;
            end;
         end loop;
      end loop;
      Model.Deployment_View.Replace_Element (DV);
   end Preprocessing;

   procedure Add_CV_Properties (Model : in out TASTE_Model) is
      Nodes,                    --  To iterate on lists of nodes
      AADL_Package,
      System_Impl : Node_Id := No_Node;
      procedure Report_Error is
      begin
         Put_Info ("No valid user-defined Concurrency View properties found:");
         Put_Info ("Task priorities, offset and stack size will use default");
         Put_Info ("values. IMPORTANT: you should set them in the editor!");
      end Report_Error;
   begin
      if Concurrency_Properties_Root = No_Node
        or else Kind (Concurrency_Properties_Root) /= K_AADL_Specification
        or else Is_Empty (Declarations (Concurrency_Properties_Root))
      then
         Put_Debug ("CV_Properties Error 1");
         Report_Error;
         return;
      end if;
      --  AADL Unparser (add with/use Ocarina.BE_AADL):
      --  Generate_AADL_Model (Concurrency_Properties_Root, False);
      Put_Info ("Analysing user-defined Concurrency View properties");

      Nodes := First_Node (Declarations (Concurrency_Properties_Root));

      --  First look for the package declaration
      while Present (Nodes) loop
         case Kind (Nodes) is
            when K_Package_Specification => AADL_Package := Nodes;
            when others                  => null;
         end case;
         Nodes := Next_Node (Nodes);
      end loop;

      if AADL_Package = No_Node then
         Put_Debug ("CV_Properties Error 2");
         Report_Error;
         return;
      end if;

      --  Then look for the system implementation
      Nodes := First_Node (Declarations (AADL_Package));
      while Present (Nodes) loop
         case Kind (Nodes) is
            when K_Component_Implementation => System_Impl := Nodes;
            when others                     => null;
         end case;
         Nodes := Next_Node (Nodes);
      end loop;
      if System_Impl = No_Node or else Is_Empty (ATN.Properties (System_Impl))
      then
         Put_Debug ("CV_Properties Error 3");
         Report_Error;
         return;
      end if;

      Nodes := First_Node (ATN.Properties (System_Impl));
      while Present (Nodes) loop --  Iterate over the properties
         declare
            Prop_Val   : Node_Id := Property_Association_Value (Nodes);
            Applies_To : constant List_Id := Applies_To_Prop (Nodes);
            Paths      : Node_Id;   --  property applies to path
            Partition,
            Thread     : Unbounded_String := Null_Unbounded_String;
            --  Prop_Name shall be Stack_Size, Priority, or Dispatch_Offset
            Prop_Name  : constant String :=
              (Get_Name_String (Display_Name (Identifier (Nodes))));

            Number, Unit : Node_Id;
            Number_Str,
            Unit_Str     : Unbounded_String := US ("");
            Found        : Boolean := False;
         begin
            if Single_Value (Prop_Val) = No_Node then
               Put_Debug ("CV_Properties Error 4 - " & Prop_Name);
               Report_Error;
               return;
            end if;
            if (Prop_Name /= "Stack_Size" and Prop_Name /= "Priority"
              and Prop_Name /= "Dispatch_Offset") or else Is_Empty (Applies_To)
            then
               Put_Debug ("Discarding unsupported CV Property: " & Prop_Name);
               goto Next_Property;
            end if;

            --  Recovering the property value - they are all signed numbers
            --  Check Ocarina-be_aadl-properties-values.adb for info
            Prop_Val := Single_Value (Prop_Val);

            if Kind (Prop_Val) /= K_Signed_AADLNumber then
               Put_Debug ("CV_Properties Error 5 - " & Prop_Name);
               Report_Error;
               return;
            end if;

            --  OK We have the value and the unit:
            Number := Number_Value (Prop_Val);
            Number_Str := US (AADL_Values.Image (Value (Number)));
            Unit   := Unit_Identifier (Prop_Val);
            if Present (Unit) then
               Unit_Str := US (Get_Name_String (Display_Name (Unit)));
            end if;

            --  Check that the units are the expected ones (kb/ms)
            if (Prop_Name = "Stack_Size"
                and then (Unit_Str /= "kbyte" and Unit_Str /= "byte"))
              or else (Prop_Name = "Dispatch_Offset" and then Unit_Str /= "ms")
            then
               Put_Error ("Unsupported units used in "
                          & "ConcurrencyView_Properties.aadl. Stack_Size in "
                          & "'byte' or 'kbyte' and Dispatch_Offset in 'ms'");
               return;
            end if;

            if Prop_Name = "Stack_Size" and Unit_Str = "kbytes" then
               --  Convert from kbytes to bytes
               declare
                  Value_In_Bytes : constant Integer :=
                    Integer'Value (To_String (Number_Str)) * 1000;
               begin
                  Number_Str := US (Value_In_Bytes'Img);
               end;
            end if;

            --  Last we find the partition and thread it applies to.
            --  (Check ocarina-be_aadl-properties.adb)
            Paths := First_Node (Applies_To);
            while Present (Paths) loop
               declare
                  Contained_Elts : constant List_Id := List_Items (Paths);
                  List_Node      : Node_Id :=
                    (if not Is_Empty (Contained_Elts)
                     then First_Node (Contained_Elts)
                     else No_Node);
               begin
                  --  The following gets the path Partition.Thread_Name
                  --  If a longer path is needed a refactoring must be done
                  while Present (List_Node) loop
                     --  Kind (List_Node) = K_Identifier
                     if Partition = Null_Unbounded_String then
                        Partition := US (Get_Name_String
                          (Display_Name (List_Node)));
                     else
                        Thread := US
                          (Get_Name_String (Display_Name (List_Node)));
                     end if;
                     exit when Thread /= Null_Unbounded_String;
                     List_Node := Next_Node (List_Node);
                  end loop;
               end;

               --  We completed the parsing of one property
               --  Prop_Name = Number_Str Unit_Str applies to Partition Thread
               Put_Debug (Prop_Name & " := " & To_String (Number_str) & " "
                          & To_String (Unit_Str) & " applies to "
                          & To_String (Partition) & "." & To_String (Thread));

               --  Checking in the generated concurrency view if the
               --  partition and thread actually exist, and apply the property
               Found := False;
               for Node of Model.Concurrency_View.Nodes loop
                  exit when Found;
                  if Node.Partitions.Contains (To_String (Partition))
                    and then Node.Partitions (To_String (Partition))
                      .Threads.Contains (To_String (Thread))
                  then
                     if Prop_Name = "Priority" then
                        Node.Partitions (To_String (Partition))
                          .Threads (To_String (Thread)).Priority := Number_Str;
                     elsif Prop_Name = "Stack_Size" then
                        Node.Partitions (To_String (Partition))
                          .Threads (To_String (Thread)).Stack_Size_In_Bytes :=
                            Number_Str;
                     elsif Prop_Name = "Dispatch_Offset" then
                        Node.Partitions (To_String (Partition))
                          .Threads (To_String (Thread)).Dispatch_Offset_Ms :=
                            Number_Str;
                     end if;
                     Found := True;
                  end if;
               end loop;
               if not Found then
                  Put_Info ("The ConcurrencyView_Properties.aadl file "
                            & "references non-existing partition/thread : "
                            & To_String (Partition) & "."
                            & To_String (Thread));
               end if;

               Paths := Next_Node (Paths);
            end loop;
         end;
         <<Next_Property>>
         Nodes := Next_Node (Nodes);
      end loop;
   end Add_CV_Properties;

end TASTE.AADL_Parser;
