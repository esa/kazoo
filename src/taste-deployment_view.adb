--  *************************** taste aadl parser ***********************  --
--  (c) 2018 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

--  Deployment View parser

with Ada.Exceptions,
     Ada.Strings.Fixed,
     System.Assertions,
     Ocarina.Instances.Queries,
     Ocarina.Instances,
     Ocarina.Files,
     Ocarina.FE_AADL.Parser,
     Ocarina.Parser,
     Ocarina.Namet,
     Ocarina.Analyzer,
     Ocarina.Options,
     Locations,
     Ocarina.ME_AADL.AADL_Instances.Nodes,
     Ocarina.ME_AADL.AADL_Instances.Nutils,
     Ocarina.ME_AADL.AADL_Instances.Entities;

package body TASTE.Deployment_View is

   use Ada.Exceptions,
       Ada.Strings.Fixed,
       System.Assertions,
       Ocarina.Instances.Queries,
       Ocarina.Namet,
       --  Ocarina.Files,
       Ocarina.FE_AADL.Parser,
       Locations,
       Ocarina.ME_AADL.AADL_Instances.Nodes,
       Ocarina.ME_AADL.AADL_Instances.Nutils,
       Ocarina.ME_AADL.AADL_Instances.Entities,
       Ocarina.ME_AADL;

   function Initialize (Root : Node_Id) return Node_Id is
      Root_Depl      : Node_Id := Root;
      Success        : Boolean;
      Root_Instance  : Node_Id;
      AADL_Language  : constant Name_Id := Get_String_Name ("aadl");
      Loc : Location;
      F   : Name_Id;
   begin
      Ocarina.FE_AADL.Parser.Add_Pre_Prop_Sets := True;

      --  Parse all AADL files possibly needed to instantiate the model
      for Each of AADL_Lib loop
         Set_Str_To_Name_Buffer (Each);
         F := Ocarina.Files.Search_File (Name_Find);
         Loc := Ocarina.Files.Load_File (F);
         Root_Depl := Ocarina.Parser.Parse (Get_String_Name ("aadl"),
                                            Root_Depl, Loc);
      end loop;

      Success := Ocarina.Analyzer.Analyze (AADL_Language, Root_Depl);

      if not Success then
         raise Deployment_View_Error with "Deployment view is incorrect";
      end if;

      Ocarina.Options.Root_System_Name :=
        Get_String_Name ("deploymentview.others");

      --  Instantiate AADL tree
      Root_Instance := Ocarina.Instances.Instantiate_Model (Root => Root);
      return Root_System (Root_Instance);
   end Initialize;

   ---------------------------
   -- AST Builder Functions --
   ---------------------------

   function Parse_Deployment_View (System : Node_Id)
                                   return Complete_Deployment_View
   is
      --  use type Node_Maps.Map;
      --  use type Taste_Busses.Vector;
      use type Bus_Connections.Vector;

      Nodes          : Node_Maps.Map;
      Node           : Taste_Node;
      Busses         : Taste_Busses.Vector;
      Conns          : Bus_Connections.Vector;
      My_Root_System : Node_Id;
      Subs           : Node_Id;
      CI             : Node_Id;

      function Parse_Bus (Elem : Node_Id; Bus : Node_Id) return Taste_Bus is
         Properties : constant Property_Maps.Map := Get_Properties_Map (CI);
         Classifier : Name_Id;
         Pkg_Name   : Name_Id := No_Name;
      begin
         Set_Str_To_Name_Buffer ("");
         if ATN.Namespace
             (Corresponding_Declaration (Bus)) /= No_Node
         then
            Set_Str_To_Name_Buffer ("");
            Get_Name_String (ATN.Name (ATN.Identifier (ATN.Namespace
                             (Corresponding_Declaration (Bus)))));
            Pkg_Name := Name_Find;
            Set_Str_To_Name_Buffer ("");
            Get_Name_String (Pkg_Name);
            Add_Str_To_Name_Buffer ("::");
            Get_Name_String_And_Append
               (Name (Identifier (Bus)));
            Classifier := Name_Find;
         else
            Classifier := Name (Identifier (Bus));
            --  No "default" Pkg_Name?
         end if;
         return Taste_Bus'(Name         =>
                             US (Get_Name_String (Name (Identifier (Elem)))),
                           AADL_Package => US (Get_Name_String (Pkg_Name)),
                           Classifier   => US (Get_Name_String (Classifier)),
                           Properties   => Properties);
      end Parse_Bus;

      function Parse_Connections (CI : Node_Id) return Bus_Connections.Vector
      is
         use Bus_Connections;
         Conn           : Node_Id;
         Bound_Bus      : Node_Id;
         Src_Port       : Node_Id;
         Src_Name       : Unbounded_String;
         Dst_Name       : Unbounded_String;
         Dst_Port       : Node_Id;
         Bound_Bus_Name : Name_Id;
         If1_Name       : Name_Id;
         If2_Name       : Name_Id;
         Result         : Bus_Connections.Vector;
      begin
         Conn := First_Node (Connections (CI));
         while Present (Conn) loop
            Bound_Bus := Get_Bound_Bus (Conn, False);
            if Bound_Bus /= No_Node then
               Bound_Bus_Name := Name
                  (Identifier (Parent_Subcomponent (Bound_Bus)));
               Src_Port := Get_Referenced_Entity (Source (Conn));
               Dst_Port := Get_Referenced_Entity (Destination (Conn));
               If1_Name := Get_Interface_Name (Src_Port);
               If2_Name := Get_Interface_Name (Dst_Port);
               --  Get_Interface_Name is v1.3.5+ only
               if If1_Name /= No_Name and If2_Name /= No_Name then
                  Src_Name := US (Get_Name_String (If1_Name));
                  Dst_Name := US (Get_Name_String (If2_Name));
               else
                  --  Keep compatibility with v1.2
                  Src_Name := US (Get_Name_String (Display_Name
                                                  (Identifier (Src_Port))));

                  Dst_Name := US (Get_Name_String (Display_Name
                                                  (Identifier (Dst_Port))));
               end if;
               Result := Result
                 & Bus_Connection'(Source_Node => Src_Name,
                                   Source_Port => US (Get_Name_String
                                     (Name (Identifier
                                      (Parent_Subcomponent
                                           (Parent_Component (Src_Port)))))),
                                   Bus_Name    =>
                                     US (Get_Name_String (Bound_Bus_Name)),
                                   Dest_Node   => Dst_Name,
                                   Dest_Port   => US (Get_Name_String
                                     (Name (Identifier
                                      (Parent_Subcomponent
                                           (Parent_Component (Src_Port)))))));
            end if;
            Conn := Next_Node (Conn);
         end loop;
         return Result;
      end Parse_Connections;

      --  Find the bus that is connected to a device through a require access
      procedure Find_Connected_Bus (Device        : Node_Id;
                                    Accessed_Bus  : out Node_Id;
                                    Accessed_Port : out Node_Id) is
         F   : Node_Id;
         Src : Node_Id;
      begin
         Accessed_Bus := No_Node;
         Accessed_Port := No_Node;
         if not Is_Empty (Features (Device)) then
            F := First_Node (Features (Device));
            while Present (F) loop
               --  The sources of F
               if not Is_Empty (AIN.Sources (F)) then
                  Src := First_Node (AIN.Sources (F));
                  if Src /= No_Node then
                     if Item (Src) /= No_Node and then
                        not Is_Empty (AIN.Sources (Item (Src))) and then
                        First_Node (AIN.Sources (Item (Src))) /= No_Node
                     then
                        Src := Item (First_Node (AIN.Sources (Item (Src))));
                        Accessed_Bus := Src;
                        Accessed_Port := F;
                     end if;
                  end if;
               end if;
               F := Next_Node (F);
            end loop;
         end if;
      end Find_Connected_Bus;

      function Parse_Device (CI : Node_Id) return Taste_Device_Driver is
         Result : Taste_Device_Driver;
         Pkg_Name                   : Name_Id;
         Accessed_Bus               : Node_Id;
         Accessed_Port              : Node_Id;
         Device_Implementation      : Node_Id;
         Configuration_Data         : Node_Id;
      begin
         Result.Name := US (Get_Name_String (Name (Identifier (CI))));

         Device_Implementation := Get_Implementation (CI);

         if Device_Implementation /= No_Node and then
            Is_Defined_Property (Device_Implementation,
                                 "deployment::configuration_type")
         then
            Configuration_Data := Get_Classifier_Property
                (Device_Implementation, "deployment::configuration_type");

            if Is_Defined_Property (Configuration_Data, "type_source_name")
            then
               Result.ASN1_Typename :=
                 US (Get_Name_String (Get_String_Property
                    (Configuration_Data, "type_source_name")));
               declare
                  ST : constant Name_Array :=
                    Get_Source_Text (Configuration_Data);
               begin
                  --  ST is a tuple (asn.1 file, .h file)
                  if ST'Length = 0 then
                     raise Device_Driver_Error with "Driver error ("
                       & To_String (Result.Name)
                       & ") : Missing configuration data";
                  end if;
                  for Index in ST'Range loop
                     Get_Name_String (ST (Index));
                     if Tail (Source => Name_Buffer (1 .. Name_Len),
                              Count  => 4) = ".asn"
                     then
                        Result.ASN1_Filename :=
                          US (Name_Buffer (1 .. Name_Len));
                     end if;
                  end loop;
               end;
            end if;
            if Result.ASN1_Filename = US ("") then
               raise Device_Driver_Error with "Driver error ("
                 & To_String (Result.Name)
                 & ") : Missing ASN.1 configuration file";
            end if;

            if Is_Defined_Property
                 (Configuration_Data, "deployment::asn1_module_name")
            then
               Result.ASN1_Module := US (Get_Name_String
                                                (Get_String_Property
                 (Configuration_Data, "deployment::asn1_module_name")));
            else
               raise Device_Driver_Error with "Driver error ("
                 & To_String (Result.Name) & ") : Missing ASN.1 module name";
            end if;
         else
            raise Device_Driver_Error with
              "Device configuration is incorrect ("
              & Get_Name_String (Name (Identifier (CI))) & ")";
         end if;

         Set_Str_To_Name_Buffer ("");
         if ATN.Namespace (Corresponding_Declaration (CI)) /= No_Node
         then
            Set_Str_To_Name_Buffer ("");
            Get_Name_String (ATN.Name (ATN.Identifier
                        (ATN.Namespace (Corresponding_Declaration (CI)))));
            Pkg_Name := Name_Find;
            --  CHECKME : I don't kwnow when this needed, check buildsupport
            --            C_Add_Package   (Get_Name_String (Pkg_Name),
            Result.Package_Name := US (Get_Name_String (Pkg_Name));
            Set_Str_To_Name_Buffer ("");
            Get_Name_String (Pkg_Name);
            Add_Str_To_Name_Buffer ("::");
            Get_Name_String_And_Append (Name (Identifier (CI)));
            Result.Device_Classifier := US (Get_Name_String (Name_Find));
         else
            Result.Device_Classifier :=
              US (Get_Name_String (Name (Identifier (CI))));
         end if;

         if Get_Bound_Processor (CI) /= No_Node then
            Set_Str_To_Name_Buffer ("");
            Result.Associated_Processor_Name := US (Get_Name_String (Name
               (Identifier (Parent_Subcomponent (Get_Bound_Processor (CI))))));
         end if;

         if Is_Defined_Property (CI, "deployment::configuration") and then
            Get_String_Property (CI, "deployment::configuration") /= No_Name
         then
            Result.Device_Configuration :=
              US (Get_Name_String
                  (Get_String_Property (CI, "deployment::configuration")));
         else
            Result.Device_Configuration := US ("noconf");
         end if;

         Find_Connected_Bus (CI, Accessed_Bus, Accessed_Port);

         if Accessed_Bus /= No_Node and then Accessed_Port /= No_Node
         then
            Result.Accessed_Bus_Name :=
              US (Get_Name_String (Name (Identifier (Accessed_Bus))));
            Result.Accessed_Port_Name :=
              US (Get_Name_String (Name (Identifier (Accessed_Port))));
         end if;
         return Result;
      exception
         when Error : Device_Driver_Error =>
            raise Device_Driver_Error with Exception_Message (Error);
         when Error : others =>
            raise Device_Driver_Error with "Device driver unknown error : "
              & Exception_Message (Error);
      end Parse_Device;

      function Parse_Partition (CI : Node_Id; Depl : Node_Id)
                                return Taste_Partition is
         Result         : Taste_Partition;
         CPU            : Node_Id;
         Processes      : Node_Id;
         P_CI           : Node_Id;
         Ref            : Node_Id;
      begin
         if Is_Defined_Property (CI, "taste_dv_properties::coverageenabled")
         then
            Result.Coverage := Get_Boolean_Property
               (CI, Get_String_Name ("taste_dv_properties::coverageenabled"));
         end if;

         CPU := Get_Bound_Processor (CI);

         Result.CPU_Name :=
          US (Get_Name_String (Name (Identifier (Parent_Subcomponent (CPU)))));

         Result.CPU_Platform := Get_Execution_Platform (CPU);

         if ATN.Namespace (Corresponding_Declaration (CPU)) /= No_Node
         then
            Set_Str_To_Name_Buffer ("");
            Get_Name_String (ATN.Name (ATN.Identifier (ATN.Namespace
                        (Corresponding_Declaration (CPU)))));
            Result.Package_Name := US (Get_Name_String (Name_Find));
            Set_Str_To_Name_Buffer ("");
            Get_Name_String
              (Get_String_Name (To_String (Result.Package_Name)));
            Add_Str_To_Name_Buffer ("::");
            Get_Name_String_And_Append (Name (Identifier (CPU)));
            Result.CPU_Classifier := US (Get_Name_String (Name_Find));
         else
            Result.CPU_Classifier :=
              US (Get_Name_String (Name (Identifier (CPU))));
            Result.Package_Name := US ("");
         end if;

         Result.Name :=
            US (Get_Name_String (ATN.Name (ATN.Component_Type_Identifier
                     (Corresponding_Declaration (CI)))));

         --  Bounded functions
         Processes := First_Node (Subcomponents (Depl));
         while Present (Processes) loop
            P_CI := Corresponding_Instance (Processes);

            if Get_Category_Of_Component (P_CI) = CC_System
              and then Is_Defined_Property (P_CI, "taste::aplc_binding")
            then
               Ref := Get_Reference_Property
                  (P_CI, Get_String_Name ("taste::aplc_binding"));

               if Ref = CI then
                  begin
                     Result.Bound_Functions.Insert (Get_Name_String (ATN.Name
                        (ATN.Component_Type_Identifier
                            (Corresponding_Declaration (P_CI)))));
                  exception
                     when Assert_Failure =>
                        Put_Info ("Detected DV from TASTE version 1.2");
                        Result.Bound_Functions.Insert
                          (Get_Name_String (Name (Identifier (Processes))));
                     when Constraint_Error =>
                        --  If the call to Insert in the set failed
                        Put_Info ("Duplicate bounded function in partition: "
                           & To_String (Result.Name));
                  end;
               end if;
            end if;
            Processes := Next_Node (Processes);
         end loop;

         return Result;
      end Parse_Partition;

      function Parse_Node (Depl_View_System : Node_Id) return Taste_Node is
         Processes : Node_Id;
         CI        : Node_Id;
         Result    : Taste_Node;
         Partition : Taste_Partition;
      begin
         Processes := First_Node (Subcomponents (Depl_View_System));

         while Present (Processes) loop
            CI := Corresponding_Instance (Processes);
            if Get_Category_Of_Component (CI) = CC_Device then
               Result.Drivers.Append (Parse_Device (CI));
            elsif Get_Category_Of_Component (CI) = CC_Process then
               Partition := Parse_Partition (CI, Depl_View_System);
               Result.Partitions.Insert (Key => To_String (Partition.Name),
                                         New_Item => Partition);
            end if;

            Processes := Next_Node (Processes);
         end loop;
         return Result;
      end Parse_Node;

   begin
      Put_Info ("Parsing deployment view");
      My_Root_System := Initialize (System);

      if Is_Empty (Subcomponents (My_Root_System)) then
         raise Empty_Deployment_View_Error;
      end if;

      Subs := First_Node (Subcomponents (My_Root_System));

      while Present (Subs) loop
         CI := Corresponding_Instance (Subs);

         if Get_Category_Of_Component (CI) = CC_System then  --  Node
            if not Is_Empty (Connections (CI)) then
               Conns := Conns & Parse_Connections (CI);  --  Checkme
            end if;

            if not Is_Empty (Subcomponents (CI)) then
               Node := Parse_Node (CI);
               Node.Name := US (Get_Name_String (Name (Identifier (Subs))));
               Nodes.Insert (Key      => To_String (Node.Name),
                             New_Item => Node);
            end if;
         elsif Get_Category_Of_Component (CI) = CC_Bus then  --  Bus
            Busses.Append (Parse_Bus (Subs, CI));
         else
            raise Deployment_View_Error with "Unknown component found: "
                                         & Get_Category_Of_Component (CI)'Img;
         end if;
         Subs := Next_Node (Subs);
      end loop;

      return DV_AST : constant Complete_Deployment_View :=
        (Nodes          => Nodes,
         Connections    => Conns,
         Busses         => Busses);
   end Parse_Deployment_View;

   procedure Dump_Nodes (DV : Complete_Deployment_View; Output : File_Type) is
   begin
      for Each of DV.Nodes loop
         Put_Line (Output, "Node : " & To_String (Each.Name));
         for Partition of Each.Partitions loop
            Put_Line (Output, "  |_ Partition        : "
                      & To_String (Partition.Name));
            Put_Line (Output, "    |_ Coverage       : "
                      & Partition.Coverage'Img);
            Put_Line (Output, "    |_ Package        : "
                      & To_String (Partition.Package_Name));
            Put_Line (Output, "    |_ CPU Name       : "
                      & To_String (Partition.CPU_Name));
            Put_Line (Output, "    |_ CPU Platform   : "
                      & Partition.CPU_Platform'Img);
            Put_Line (Output, "    |_ CPU Classifier : "
                      & To_String (Partition.CPU_Classifier));
            Put (Output, "    |_ Contains       : ");
            for Bounded of Partition.Bound_Functions loop
               Put (Output, Bounded & " ");
            end loop;
            New_Line (Output);
         end loop;
         for Driver of Each.Drivers loop
            Put_Line (Output, "  |_ Driver : " & To_String (Driver.Name));
            Put_Line (Output, "    |_ Package       : "
                      & To_String (Driver.Package_Name));
            Put_Line (Output, "    |_ Classifier    : "
                      & To_String (Driver.Device_Classifier));
            Put_Line (Output, "    |_ Processor     : "
                      & To_String (Driver.Associated_Processor_Name));
            Put_Line (Output, "    |_ Configuration : "
                      & To_String (Driver.Device_Configuration));
            Put_Line (Output, "    |_ Bus_Name      : "
                      & To_String (Driver.Accessed_Bus_Name));
            Put_Line (Output, "    |_ Port_Name     : "
                      & To_String (Driver.Accessed_Port_Name));
            Put_Line (Output, "    |_ ASN.1 File    : "
                      & To_String (Driver.ASN1_Filename));
            Put_Line (Output, "    |_ ASN.1 Type    : "
                      & To_String (Driver.ASN1_Typename));
            Put_Line (Output, "    |_ ASN.1 Module  : "
                      & To_String (Driver.ASN1_Module));
         end loop;
      end loop;
   end Dump_Nodes;

   procedure Dump_Connections (DV     : Complete_Deployment_View;
                               Output : File_Type) is
   begin
      for Each of DV.Connections loop
         Put_Line (Output, "Connection on bus : " & To_String (Each.Bus_Name));
         Put_Line (Output, "  |_ Source Node : "
                   & To_String (Each.Source_Node));
         Put_Line (Output, "  |_ Source Port : "
                   & To_String (Each.Source_Port));
         Put_Line (Output, "  |_ Dest Node   : " & To_String (Each.Dest_Node));
         Put_Line (Output, "  |_ Dest Port   : " & To_String (Each.Dest_Port));
      end loop;
   end Dump_Connections;

   procedure Dump_Busses (DV : Complete_Deployment_View; Output : File_Type) is
   begin
      for Each of DV.Busses loop
         Put_Line (Output, "Bus : " & To_String (Each.Name));
         Put_Line (Output, "  |_ Package    : "
                   & To_String (Each.AADL_Package));
         Put_Line (Output, "  |_ Classifier : " & To_String (Each.Classifier));
         for Prop of Each.Properties loop
            Put_Line (Output, "    |_ Property: " & To_String (Prop.Name)
                      & " = " & To_String (Prop.Value));
         end loop;
      end loop;
   end Dump_Busses;

   procedure Debug_Dump (DV : Complete_Deployment_View; Output : File_Type) is
   begin
      DV.Dump_Nodes       (Output);
      DV.Dump_Busses      (Output);
      DV.Dump_Connections (Output);
   end Debug_Dump;

end TASTE.Deployment_View;
