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
     GNAT.Command_Line,
     Errors,
     Locations,
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
    Locations,
    Ocarina.Namet,
    Ocarina;

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
      return Cfg;
   end Initialize;

   function Parse_Project return TASTE_Model is
      Result : TASTE_Model;
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
            Result.Deployment_View := Parse_Deployment_View (Deployment_Root);
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
      Ocarina.Reset;

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
      for Node of Model.Deployment_View.Nodes loop
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
         for RI of Partition.Blocks (Block_Id).Required loop
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
                    Dist.Function_Name & "_" & Dist.Interface_Name;
                  Port_Name : constant Unbounded_String := RI.Name;
                  --  Remote_Thread_Name & "_" & Dist.Interface_Name;
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
         Deployment         => Model.Deployment_View,
         Configuration      => Model.Configuration,
         others             => <>);
   begin
      --  Initialize the lists of nodes and partitions based on the DV
      for Node of Model.Deployment_View.Nodes loop
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
              Model.Deployment_View.Find_Node (Function_Name);
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
              (Name     => F.Name,
               Language => US (TASTE.Backend.Language_Spelling (F)),
               Node     => Node,
               others   => <>);
         begin
            if not Node.Has_Value then
               --  Ignore functions that are not mapped to a node/partition
               goto Continue;
            end if;

            for PI of F.Provided loop
               declare
                  New_PI : Protected_Block_PI := (Name   => PI.Name,
                                                  PI     => PI,
                                                  others => <>);
               begin
                  New_PI.PI.RCM := (if F.Provided.Length = 1
                                    then Unprotected_Operation
                                    else Protected_Operation);
                  --  Check in the DV if any caller is remote
                  for Remote of PI.Remote_Interfaces loop
                     declare
                        Remote_Node : constant Option_Node.Option :=
                          Model.Deployment_View.Find_Node
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
                  Block.Provided.Insert (Key      => To_String (PI.Name),
                                         New_Item => New_PI);
               end;
               if PI.RCM = Cyclic_Operation or PI.RCM = Sporadic_Operation then
                  declare
                     Thread : constant AADL_Thread :=
                       (Name                 => F.Name & "_" & PI.Name,
                        RCM                  => US (PI.RCM'Img),
                        Need_Mutex           => (F.Provided.Length > 1),
                        Entry_Port_Name      => PI.Name,
                        Protected_Block_name => Block.Name,
                        Node                 => Block.Node,
                        PI                   => PI,
                        Output_Ports         => Get_Output_Ports (Model, F));
                  begin
                     CV.Nodes
                       (Node_Name).Partitions (Partition_Name).Threads.Include
                       (Key      => To_String (Thread.Name),
                        New_Item => Thread);
                  end;
               end if;
            end loop;
            Block.Required := F.Required;
            --  Add the block to the Concurrency View
            CV.Nodes (Node_Name).Partitions (Partition_Name).Blocks.Insert
              (Key      => To_String (Block.Name),
               New_Item => Block);
         end;
         <<Continue>>
      end loop;

      for Node of CV.Nodes loop
         for Partition of Node.Partitions loop
            --  Find and set protected blocks calling threads
            Set_Calling_Threads (Partition);

            --  Define ports at partition (process) level
            --  (ports are for all interfaces of a function are not located
            --   in the same partition of the system)
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
                              --  CHECKME: if the key is already present,
                              --  this will fail (test-tsp1).
                              Partition.Out_Ports.Insert
                                (Key      => To_String (Out_Port.RI.Name),
                                 New_Item => (Port_Name   => Out_Port.RI.Name,
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
            Model.Deployment_View.Debug_Dump (Output);
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
end TASTE.AADL_Parser;
