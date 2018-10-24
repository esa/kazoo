--  ************************ TASTE AADL Parser **************************  --
--  Based on Ocarina ****************************************************  --
--  (c) 2018 European Space Agency - maxime.perrotin@esa.int
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
   begin
      Banner;
      --  Parse arguments before initializing Ocarina, otherwise Ocarina eats
      --  some arguments (all file parameters).
      Parse_Command_Line (Cfg);
      Initialize_Ocarina;

      AADL_Language := Get_String_Name ("aadl");

      if Cfg.Interface_View.all'Length = 0 and not Cfg.Check_Data_View then
         --  Use "InterfaceView.aadl" by default, if nothing else is specified
         --  and if the tool is not only called to check the data view
         Cfg.Interface_View := Default_Interface_View'Access;
      end if;

      --  An interface view is expected, look for it and parse it
      if Cfg.Interface_View.all'Length > 0 then
         Set_Str_To_Name_Buffer (Cfg.Interface_View.all);

         File_Name := Ocarina.Files.Search_File (Name_Find);
         if File_Name = No_Name then
            raise AADL_Parser_Error
              with "File not found : " & Cfg.Interface_View.all;
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
      end if;

      if Cfg.Glue then
         --  Look for a deployment view (or DeploymentView.aadl by default)
         --  if the glue generation is requested. Not needed for skeletons.
         if Cfg.Deployment_View.all'Length = 0 then
            Cfg.Deployment_View := Default_Deployment_View'Access;
         end if;

         Set_Str_To_Name_Buffer (Cfg.Deployment_View.all);

         File_Name := Ocarina.Files.Search_File (Name_Find);
         if File_Name = No_Name then
            raise AADL_Parser_Error
              with "File not found : " & Cfg.Deployment_View.all;
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

      if Cfg.Data_View.all'Length > 0 then
         Set_Str_To_Name_Buffer (Cfg.Data_View.all);
         File_Name := Ocarina.Files.Search_File (Name_Find);
         if File_Name = No_Name then
            raise AADL_Parser_Error with "Could not find " & Cfg.Data_View.all;
         end if;
      else
         --  Try with default name (DataView.aadl)
         Set_Str_To_Name_Buffer (Default_Data_View);
         File_Name := Ocarina.Files.Search_File (Name_Find);
         if File_Name /= No_Name then
            Cfg.Data_View := Default_Data_View'Access;
         elsif Cfg.Check_Data_View then
            --  No dataview found, while user asked explicitly for a check
            raise AADL_Parser_Error with "Could not find DataView.aadl";
         end if;
      end if;

      if File_Name /= No_Name then
         Put_Info ("Parsing " & Cfg.Data_View.all);

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

         if Result.Configuration.Deployment_View.all'Length > 0 then
            AADL_Lib.Append (Result.Configuration.Interface_View.all);
            Result.Deployment_View := Parse_Deployment_View (Deployment_Root);
         end if;
      end if;

      if Result.Configuration.Data_View.all'Length > 0 then
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

         for RI of Func.Required loop
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
                  Dist  : constant Remote_Entity :=
                    RI.Remote_Interfaces.First_Element;
                  New_P : constant Port :=
                    (Remote_Thread =>
                       Dist.Function_Name & "_" & Dist.Interface_Name,
                     Remote_PI     => Dist.Interface_Name);
               begin
                  Ports_Map.Include
                    (Key => To_String
                       (New_P.Remote_Thread & "_" & New_P.Remote_PI),
                     New_Item => New_P);
               end;
            end if;
         end loop;
      end Rec_Find_Thread;
   begin
      Rec_Find_Thread (Ports_Map => Result,
                       Visited   => Visited_Functions,
                       Func      => F);
      return Result;
   end Get_Output_Ports;

   procedure Add_Concurrency_View (Model : in out TASTE_Model) is
      Result : Taste_Concurrency_View;
   begin
      --  Create one thread per Cyclic and Sporadic interface
      --  Create one protected block per application code
      for F of Model.Interface_View.Flat_Functions loop
         declare
            Block : Protected_Block :=
              (Name   => F.Name,
               Node   => Model.Deployment_View.Find_Node (To_String (F.Name)),
               others => <>);
         begin
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
                        Entry_Port_Name      => PI.Name,
                        Protected_Block_name => Block.Name,
                        Node                 => Block.Node,
                        Output_Ports         => Get_Output_Ports (Model, F));
                  begin
                     --  Todo: add Thread.Output_Ports
                     Result.Threads.Include
                       (Key      => To_String (Thread.Name),
                        New_Item => Thread);
                  end;
               end if;

            end loop;
            Block.Required := F.Required;
            --  Find calling threads and add them to Block.Calling_Threads
            --  Add the block to the Concurrency View
            Result.Blocks.Insert (Key      => To_String (Block.Name),
                                  New_Item => Block);
         end;
      end loop;

      Model.Concurrency_View := Result;
   end Add_Concurrency_View;

   procedure Dump (Model : TASTE_Model) is
      Output_Path : constant String := Model.Configuration.Output_Dir.all
                      & "/Debug";
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

         if Model.Configuration.Deployment_View.all'Length > 0 then
            Create (File => Output,
                    Mode => Out_File,
                    Name => Output_Path & "/DeploymentView.dump");
            Put_Info ("Dump of the Deployment View");
            Model.Deployment_View.Debug_Dump (Output);
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
