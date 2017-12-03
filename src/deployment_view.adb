--  *************************** taste aadl parser ***********************  --
--  (c) 2017 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

--  Deployment View parser

with --  Ada.Text_IO,
     --  Ada.Exceptions,
     Ocarina.Instances.Queries,
     Ocarina.Backends.Properties,
     Ocarina.Instances,
     Ocarina.Namet,
     Ocarina.Analyzer,
     Ocarina.Options,
     Ocarina.ME_AADL.AADL_Instances.Nodes,
     Ocarina.ME_AADL.AADL_Instances.Nutils,
     Ocarina.ME_AADL.AADL_Instances.Entities;
     --  Ocarina.Backends.Utils;

package body Deployment_View is

   use --  Ada.Text_IO,
       --  Ada.Exceptions,
       Ocarina.Instances.Queries,
       Ocarina.Backends.Properties,
       Ocarina.Namet,
       Ocarina.ME_AADL.AADL_Instances.Nodes,
       Ocarina.ME_AADL.AADL_Instances.Nutils,
       Ocarina.ME_AADL.AADL_Instances.Entities,
       Ocarina.ME_AADL;
       --  Ocarina.Backends.Utils;

   function Initialize (Root : Node_Id) return Node_Id is
      Success        : Boolean;
      Root_Instance  : Node_Id;
      AADL_Language  : constant Name_Id := Get_String_Name ("aadl");
   begin
      Success := Ocarina.Analyzer.Analyze (AADL_Language, Root);

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

   function AADL_To_Ada_DV (System : Node_Id) return Complete_Deployment_View
   is
      use type Node_Maps.Map;
      use type Taste_Busses.Vector;
      use type Bus_Connections.Vector;

      Nodes          : Node_Maps.Map;
      Busses         : Taste_Busses.Vector;
      Conns          : Bus_Connections.Vector;
      My_Root_System : Node_Id;
      Subs           : Node_Id;
      CI             : Node_Id;

      function Parse_Bus (Elem : Node_Id; Bus : Node_Id) return Taste_Bus is
         Properties : constant Property_Maps.Map := Get_Properties_Map (CI);
         Classifier : Name_Id := No_Name;
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
               if not Is_Empty (Sources (F)) then
                  Src := First_Node (Sources (F));
                  if Src /= No_Node then
                     if Item (Src) /= No_Node and then
                        not Is_Empty (Sources (Item (Src))) and then
                        First_Node (Sources (Item (Src))) /= No_Node
                     then
                        Src := Item (First_Node (Sources (Item (Src))));
                        Accessed_Bus := Src;
                        Accessed_Port := F;
                     end if;
                  end if;
               end if;
               F := Next_Node (F);
            end loop;
         end if;
      end Find_Connected_Bus;

      function Parse_Device (dummy_CI : Node_Id) return Taste_Device_Driver is
         Result : Taste_Device_Driver;
         Device_Classifier          : Name_Id   := No_Name;
         Pkg_Name                   : Name_Id   := No_Name;
         Associated_Processor_Name  : Name_Id   := No_Name;
         Accessed_Bus               : Node_Id   := No_Node;
         Accessed_Port              : Node_Id   := No_Node;
         Device_ASN1_Filename       : Name_Id   := No_Name;
         Device_Implementation      : Node_Id   := No_Node;
         Configuration_Data         : Node_Id   := No_Node;
         Device_ASN1_Typename       : Name_Id   := No_Name;
         Device_ASN1_Module         : Name_Id   := No_Name;
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
               Device_ASN1_Typename :=
                 (Get_String_Property
                    (Configuration_Data, "type_source_name"));
               declare
                  ST : constant Name_Array :=
                    Get_Source_Text (Configuration_Data);
               begin
                  for Index in ST'Range loop
                     Get_Name_String (ST (Index));
                     if Name_Buffer (Name_Len - 3 .. Name_Len) = ".asn"
                     then
                        Device_ASN1_Filename := Get_String_Name
                          (Name_Buffer (1 .. Name_Len));
                     end if;
                  end loop;
               end;
            end if;
            if Is_Defined_Property
                 (Configuration_Data, "deployment::asn1_module_name")
            then
               Device_ASN1_Module := Get_String_Property
                 (Configuration_Data, "deployment::asn1_module_name");
            else
               Device_ASN1_Module := Get_String_Name ("nomod");
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
--            C_Add_Package   (Get_Name_String (Pkg_Name),
            Set_Str_To_Name_Buffer ("");
            Get_Name_String (Pkg_Name);
            Add_Str_To_Name_Buffer ("::");
            Get_Name_String_And_Append (Name (Identifier (CI)));
            Device_Classifier := Name_Find;
         else
            Device_Classifier := Name (Identifier (CI));
         end if;

         if Get_Bound_Processor (CI) /= No_Node then
            Set_Str_To_Name_Buffer ("");
            Associated_Processor_Name := Name
               (Identifier (Parent_Subcomponent (Get_Bound_Processor (CI))));
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

         if Device_ASN1_Filename = No_Name
           or Associated_Processor_Name = No_Name
         then
            raise Device_Driver_Error with "Missing ASN.1 configuration file"
              & " for device driver specification "
              & Get_Name_String (Device_Classifier);
         end if;

         Result.Device_Classifier :=
           US (Get_Name_String (Device_Classifier));
         Result.Associated_Processor_Name :=
           US (Get_Name_String (Associated_Processor_Name));

         Result.ASN1_Filename :=
           US (Get_Name_String (Device_ASN1_Filename));
         Result.ASN1_Typename :=
           US (Get_Name_String (Device_ASN1_Typename));
         Result.ASN1_Module := US (Get_Name_String (Device_ASN1_Module));

         return Result;
      end Parse_Device;

      function Parse_Node (Depl_View_System : Node_Id)
                            return Taste_Node is
         Processes : Node_Id;
         CI        : Node_Id;
         Result    : Taste_Node;
      begin
         Processes := First_Node (Subcomponents (Depl_View_System));

         while Present (Processes) loop
            CI := Corresponding_Instance (Processes);
            if Get_Category_Of_Component (CI) = CC_Device then
               Result.Drivers.Append (Parse_Device (CI));
            elsif Get_Category_Of_Component (CI) = CC_Process then
               --  Partitions?
               null;
            end if;

            Processes := Next_Node (Processes);
         end loop;

         return Result;

      end Parse_Node;

   begin
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
               Nodes.Insert (Key => Get_Name_String (Name (Identifier (Subs))),
                             New_Item => Parse_Node (CI));
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
   end AADL_To_Ada_DV;

   procedure Debug_Dump_DV (DV : Complete_Deployment_View) is null;
end Deployment_View;
