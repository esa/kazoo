--  ************************ TASTE AADL Parser **************************  --
--  Based on Ocarina ****************************************************  --
--  (c) 2017 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file
pragma Warnings (Off);
with Ada.Strings.Unbounded,
     Ada.Command_Line,
     Ada.Exceptions,

     Ada.Text_IO,
     Ada.Containers.Indefinite_Vectors,
     GNAT.OS_Lib,
     Errors,
     Locations,
     Ocarina.Namet,
     Ocarina.Types,
     Ocarina.Analyzer,
     Ocarina.Backends.Properties,
     Ocarina.Configuration,
     Ocarina.Files,
     Ocarina.Options,
     Ocarina.Instances,
     Ocarina.ME_AADL.AADL_Instances.Entities,
     Ocarina.ME_AADL.AADL_Instances.Nodes,
     Ocarina.ME_AADL.AADL_Instances.Nutils,
     Ocarina.Parser,
     Ocarina.FE_AADL.Parser,
     Parser_Utils,
     Interface_View;

use Ada.Strings.Unbounded,
    Ada.Text_IO,
    Ada.Exceptions,
    Locations,
    Ocarina.Namet,
    Ocarina.Types,
    Ocarina,
    Ocarina.Analyzer,
    Ocarina.Backends.Properties,
    Ocarina.Instances,
    Ocarina.ME_AADL,
    Ocarina.ME_AADL.AADL_Instances.Entities,
    Ocarina.ME_AADL.AADL_Instances.Nodes,
    Ocarina.ME_AADL.AADL_Instances.Nutils,
    Ocarina.Backends.Properties,
    Parser_Utils,
    Interface_View,
    GNAT.OS_Lib;

procedure AADL_Parser is

   AADL_Language : Name_Id;

   Interface_Root    : Node_Id := No_Node;
   Deployment_root   : Node_Id := No_Node;
   Dataview_root     : Node_ID := No_Node;
   Success           : Boolean;
   OutDir            : Integer := 0;
   Stack_Val         : Integer := 0;
   Timer_Resolution  : Integer := 0;
   Interface_View    : Integer := 0;
   Concurrency_view  : Integer := 0;
   Data_View         : Integer := 0;
   Generate_glue     : Boolean := false;
   Keep_case         : Boolean := false;
   AADL_Version      : AADL_Version_Type := Ocarina.AADL_V2;

   procedure Parse_Command_Line;
   procedure Process_Deployment_View (My_Root : Node_Id);
   --  procedure Process_DataView (My_Root : Node_Id);
   procedure Browse_Deployment_View_System
     (My_System : Node_Id; NodeName : String) with Unreferenced;

   --  Find the bus that is connected to a device through a require
   --  access.

   ------------------------
   -- Find_Connected_Bus --
   ------------------------

   procedure Find_Connected_Bus (Device : Node_Id;
                                 Accessed_Bus : out Node_Id;
                                 Accessed_Port : out Node_Id) is
      F : Node_Id;
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

   ----------------------------
   -- Process_Interface_View --
   ----------------------------

         --  Set the output directory
--        if OutDir > 0 then
--           C_Set_OutDir (Ada.Command_Line.Argument (Outdir),
--                         Ada.Command_Line.Argument (Outdir)'Length);
--        end if;
--
--        --  Set the stack value
--        if Stack_Val > 0 then
--           C_Set_Stack (Ada.Command_Line.Argument (stack_val),
--                        Ada.Command_Line.Argument (stack_val)'Length);
--        end if;
--
--        --  Set the timer resolution value
--        if Timer_Resolution > 0 then
--           C_Set_Timer_Resolution
--             (Ada.Command_Line.Argument (Timer_Resolution),
--              Ada.Command_Line.Argument (Timer_Resolution)'Length);
--        end if;

         --  Current_function is read from the list of system subcomponents

   -----------------------------
   -- Process_Deployment_View --
   -----------------------------

   procedure Process_Deployment_View (My_Root : Node_Id) is null;
--     My_Root_System : Node_Id;
--     CI             : Node_Id;
--     Root_Instance  : Node_Id;
--  begin
--
--     if My_Root /= No_Node and then Concurrency_view /= 0 then
--        --  Analyze the tree
--
--        Success := Ocarina.Analyzer.Analyze (AADL_Language, My_Root);
--        Exit_On_Error (not Success, "Deployment view is incorrect");
--        if Success then
--           --  After making sure that the Deployment view is correct, set
--           --  the Glue flag
--
--           if generate_glue then
--              C_Set_Glue;
--           end if;
--
--           --  Put_Line (Get_Name_String
--           --    (Get_Ellidiss_Tool_Version (My_Root)));
--
--           Ocarina.Options.Root_System_Name :=
--                 Get_String_Name ("deploymentview.others");
--
--           --  Instantiate AADL tree
--           Root_Instance := Instantiate_Model (Root => My_Root);
--
--           My_Root_System := Root_System (Root_Instance);
--
--           --  Name of the ROOT SYSTEM (not implementation)
--
--           declare
--              My_Root_System_Name : constant String :=
--                Get_Name_String
--                (Ocarina.ME_AADL.AADL_Tree.Nodes.Name
--                   (Ocarina.ME_AADL.AADL_Tree.Nodes.
--                      Component_Type_Identifier
--                      (Corresponding_Declaration
--                       (My_Root_System))));
--           begin
--              C_Set_Root_node
--                  (My_Root_System_Name, My_Root_System_Name'Length);
--           end;
--
--           if not Is_Empty (Subcomponents (My_Root_System)) then
--              Subs := First_Node (Subcomponents (My_Root_System));
--
--              while Present (Subs) loop
--                 CI := Corresponding_Instance (Subs);
--
--                 if Get_Category_Of_Component (CI) = CC_System then
--                    Browse_Deployment_View_System
--                        (CI, Get_Name_String (Name (Identifier (Subs))));
--                 elsif Get_Category_Of_Component (CI) = CC_Bus then
--                    declare
--                       --  Get the list of properties attaches to the bus
--                       Properties : constant Property_Maps.Map :=
--                                                     Get_Properties_Map (CI);
--                       Bus_Classifier : Name_Id := No_Name;
--                       Pkg_Name : Name_Id := No_Name;
--                    begin
--                       --  Iterate on the BUS Instance properties
--                       for each in Properties.Iterate loop
--                          null;
--                          --  Put_Line (Property_Maps.Key (each) & " : " &
--                          --            Property_Maps.Element (each));
--                       end loop;
--                       Set_Str_To_Name_Buffer ("");
--                       if ATN.Namespace
--                           (Corresponding_Declaration (CI)) /= No_Node
--                       then
--                          Set_Str_To_Name_Buffer ("");
--                          Get_Name_String
--                             (ATN.Name
--                                (ATN.Identifier
--                                   (ATN.Namespace
--                                      (Corresponding_Declaration (CI)))));
--                          Pkg_Name := Name_Find;
--                          C_Add_Package
--                             (Get_Name_String (Pkg_Name),
--                             Get_Name_String (Pkg_Name)'Length);
--                          Set_Str_To_Name_Buffer ("");
--                          Get_Name_String (Pkg_Name);
--                          Add_Str_To_Name_Buffer ("::");
--                          Get_Name_String_And_Append
--                             (Name (Identifier (CI)));
--                          Bus_Classifier := Name_Find;
--                       else
--                          Bus_Classifier := Name (Identifier (CI));
--                       end if;
--                       C_New_Bus
--                        (Get_Name_String (Name (Identifier (Subs))),
--                         Get_Name_String (Name (Identifier (Subs)))'Length,
--                         Get_Name_String (Bus_Classifier),
--                         Get_Name_String (Bus_Classifier)'Length);
--                       C_End_Bus;
--                    end;
--                 end if;
--                 Subs := Next_Node (Subs);
--              end loop;
--           end if;
--        end if;
--     end if;
--  end Process_Deployment_View;

   -------------------------------------
   -- Load_Deployment_View_Properties --
   -------------------------------------

   procedure Load_Deployment_View_Properties (Root_Tree : in out Node_Id) is
      Loc : Location;
      F : Name_Id;
      package Vectors is new Ada.Containers.Indefinite_Vectors (Natural,
                                                                String);
      use Vectors;
      AADL_Lib : Vectors.Vector;

   begin
      if Root_Tree = No_Node then
         return;
      end if;
      AADL_Lib := AADL_Lib &
                  Ada.Command_Line.Argument (Interface_View) &
                  "aadl_project.aadl" &
                  "taste_properties.aadl" &
                  "Cheddar_Properties.aadl" &
                  "communication_properties.aadl" &
                  "deployment_properties.aadl" &
                  "thread_properties.aadl" &
                  "timing_properties.aadl" &
                  "programming_properties.aadl" &
                  "memory_properties.aadl" &
                  "modeling_properties.aadl" &
                  "arinc653.aadl" &
                  --  "arinc653_properties.aadl" &
                  "base_types.aadl" &
                  "data_model.aadl" &
                  "deployment.aadl";

      Ocarina.FE_AADL.Parser.Add_Pre_Prop_Sets := True;

      for each of AADL_Lib loop
         Set_Str_To_Name_Buffer (each);
         F := Ocarina.Files.Search_File (Name_Find);
         Loc := Ocarina.Files.Load_File (F);
         Root_Tree := Ocarina.Parser.Parse (AADL_Language, Root_Tree, Loc);
      end loop;
   end Load_Deployment_View_Properties;

   -----------------------------------
   -- Browse_Deployment_View_System --
   -----------------------------------

   procedure Browse_Deployment_View_System
       (My_System : Node_Id; NodeName : String) is
--      Processes         : Node_Id;
--      Processes2        : Node_Id;
--      Tmp_CI            : Node_Id;
--      Tmp_CI2           : Node_Id;
--      Ref               : Node_Id;
--      CPU               : Node_Id;
--      CPU_Name          : Name_Id := No_Name;
--      Pkg_Name          : Name_Id := No_Name;
--      CPU_Classifier    : Name_Id := No_Name;
--      CPU_Platform      : Supported_Execution_Platform := Platform_None;
      Conn              : Node_Id;
      Bound_Bus         : Node_Id;
      Src_Port          : Node_Id;
      Src_Name          : Unbounded_String;
      Dst_Name          : Unbounded_String;
      Dst_Port          : Node_Id;
      Bound_Bus_Name    : Name_Id;
      If1_Name          : Name_Id := No_Name;
      If2_Name          : Name_Id := No_Name;
   begin
      if not Is_Empty (Connections (My_System)) then
         Conn := First_Node (Connections (My_System));
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
--             Put_Line (To_String (Src_Name) & " -> " & To_String (Dst_Name));
--              C_New_Connection
--                 (Get_Name_String
--                    (Name (Identifier
--                       (Parent_Subcomponent
--                          (Parent_Component (Src_Port))))),
--                  Get_Name_String
--                    (Name (Identifier
--                       (Parent_Subcomponent
--                          (Parent_Component (Src_Port)))))'Length,
--                  To_String (Src_Name),
--                  To_String (Src_Name)'Length,
--                  Get_Name_String (Bound_Bus_Name),
--                  Get_Name_String (Bound_Bus_Name)'Length,
--                  Get_Name_String
--                     (Name (Identifier
--                        (Parent_Subcomponent
--                           (Parent_Component (Dst_Port))))),
--                  Get_Name_String
--                     (Name (Identifier
--                        (Parent_Subcomponent
--                        (Parent_Component (Dst_Port)))))'Length,
--                  To_String (Dst_Name),
--                  To_String (Dst_Name)'Length);
--
--              C_End_Connection;
            end if;
            Conn := Next_Node (Conn);
         end loop;
      end if;

--     if not Is_Empty (Subcomponents (My_System)) then
--        C_New_Drivers_Section;
--        Processes := First_Node (Subcomponents (My_System));
--
--        while Present (Processes) loop
--           Tmp_CI := Corresponding_Instance (Processes);
--
--           if Get_Category_Of_Component (Tmp_CI) = CC_Device then
--              declare
--                 Device_Classifier          : Name_Id   := No_Name;
--                 Pkg_Name                   : Name_Id   := No_Name;
--                 Associated_Processor_Name  : Name_Id   := No_Name;
--                 Accessed_Bus               : Node_Id   := No_Node;
--                 Accessed_Port              : Node_Id   := No_Node;
--                 Accessed_Bus_Name          : Name_Id   := No_Name;
--                 Accessed_Port_Name         : Name_Id   := No_Name;
--                 Device_Configuration       : Name_Id   := No_Name;
--                 Device_Configuration_Len   : Integer   := 0;
--                 Device_ASN1_Filename       : Name_Id   := No_Name;
--                 Device_ASN1_Filename_Len   : Integer   := 0;
--                 Device_Implementation      : Node_Id   := No_Node;
--                 Configuration_Data         : Node_Id   := No_Node;
--                 Device_ASN1_Typename       : Name_Id   := No_Name;
--                 Device_ASN1_Typename_Len   : Integer   := 0;
--                 Device_ASN1_Module         : Name_Id   := No_Name;
--                 Device_ASN1_Module_Len     : Integer   := 0;
--              begin
--
--                 Device_Implementation := Get_Implementation (Tmp_CI);
--                 if Device_Implementation /= No_Node and then
--                    Is_Defined_Property (Device_Implementation,
--                                         "deployment::configuration_type")
--                 then
--                    Configuration_Data
--                       := Get_Classifier_Property
--                          (Device_Implementation,
--                          "deployment::configuration_type");
--                    if Configuration_Data /= No_Node and then
--                       Is_Defined_Property
--                          (Configuration_Data, "type_source_name")
--                    then
--                          Device_ASN1_Typename :=
--                             (Get_String_Property
--                                (Configuration_Data, "type_source_name"));
--
--                          Device_ASN1_Typename_Len :=
--                             Get_Name_String (Device_ASN1_Typename)'Length;
--                          declare
--                             ST : constant Name_Array
--                                := Get_Source_Text (Configuration_Data);
--                          begin
--                             Exit_On_Error
--                                (ST'Length = 0,
--                                 "Source_Text property of " &
--                                 "configuration data" &
--                                 " must have at least one element " &
--                                 "(the header file).");
--
--                             for Index in ST'Range loop
--                                Get_Name_String (ST (Index));
--                                if Name_Buffer (Name_Len - 3 .. Name_Len)
--                                   = ".asn"
--                                then
--                                   Device_ASN1_Filename := Get_String_Name
--                                      (Name_Buffer (1 .. Name_Len));
--                                   Device_ASN1_Filename_Len :=
--                                      Get_Name_String
--                                         (Device_ASN1_Filename)'Length;
--                                end if;
--                             end loop;
--
--                             Exit_On_Error
--                                (Device_ASN1_Filename = No_Name,
--                                "Cannot find ASN file " &
--                                 "that implements the device " &
--                                 "configuration type");
--                          end;
--                    end if;
--                    if Configuration_Data /= No_Node and then
--                       Is_Defined_Property
--                         (Configuration_Data, "deployment::asn1_module_name")
--                    then
--                       Device_ASN1_Module :=
--                        Get_String_Property
--                     (Configuration_Data, "deployment::asn1_module_name");
--                    else
--                       Device_ASN1_Module := Get_String_Name ("nomod");
--                    end if;
--
--                    Device_ASN1_Module_Len :=
--                      Get_Name_String (Device_ASN1_Module)'Length;
--
--                 else
--                    Exit_On_Error (true,
--                            "Device configuration is incorrect (" &
--                            Get_Name_String (Name (Identifier (Tmp_CI))) &
--                            ")");
--                 end if;
--
--                 Set_Str_To_Name_Buffer ("");
--                 if ATN.Namespace (Corresponding_Declaration
--                                                         (Tmp_CI)) /= No_Node
--                 then
--
--                    Set_Str_To_Name_Buffer ("");
--                    Get_Name_String
--                    (ATN.Name
--                     (ATN.Identifier
--                      (ATN.Namespace
--                       (Corresponding_Declaration (Tmp_CI)))));
--                    Pkg_Name := Name_Find;
--                    C_Add_Package
--                       (Get_Name_String (Pkg_Name),
--                        Get_Name_String (Pkg_Name)'Length);
--                    Set_Str_To_Name_Buffer ("");
--                    Get_Name_String (Pkg_Name);
--                    Add_Str_To_Name_Buffer ("::");
--                    Get_Name_String_And_Append (Name (Identifier (Tmp_CI)));
--                    Device_Classifier := Name_Find;
--                 else
--                    Device_Classifier := Name (Identifier (Tmp_CI));
--                 end if;
--
--                 if Get_Bound_Processor (Tmp_CI) /= No_Node then
--                    Set_Str_To_Name_Buffer ("");
--                    Associated_Processor_Name := Name
--                       (Identifier
--                          (Parent_Subcomponent
--                             (Get_Bound_Processor (Tmp_CI))));
--                 end if;
--
--                 if Is_Defined_Property
--                    (Tmp_CI, "deployment::configuration") and then
--                    Get_String_Property
--                       (Tmp_CI, "deployment::configuration") /= No_Name
--                 then
--                       Get_Name_String
--                          (Get_String_Property
--                             (Tmp_CI, "deployment::configuration"));
--                    Device_Configuration := Name_Find;
--                 else
--                    Device_Configuration := Get_String_Name ("noconf");
--                 end if;
--
--                 Device_Configuration_Len := Get_Name_String
--                   (Device_Configuration)'Length;
--
--                 Find_Connected_Bus (Tmp_CI, Accessed_Bus, Accessed_Port);
--                 if Accessed_Bus /= No_Node and then
--                    Accessed_Port /= No_Node
--                 then
--                    Accessed_Bus_Name := Name (Identifier (Accessed_Bus));
--                    Accessed_Port_Name := Name (Identifier (Accessed_Port));
--                 end if;
--
--                 if Associated_Processor_Name /= No_Name then
--                    C_New_Device
--                       (Get_Name_String (Name (Identifier (Processes))),
--                        Get_Name_String
--                          (Name (Identifier (Processes)))'Length,
--                        Get_Name_String (Device_Classifier),
--                        Get_Name_String (Device_Classifier)'Length,
--                        Get_Name_String (Associated_Processor_Name),
--                        Get_Name_String (Associated_Processor_Name)'Length,
--                        Get_Name_String (Device_Configuration),
--                        Device_Configuration_Len,
--                        Get_Name_String (Accessed_Bus_Name),
--                        Get_Name_String (Accessed_Bus_Name)'Length,
--                        Get_Name_String (Accessed_Port_Name),
--                        Get_Name_String (Accessed_Port_Name)'Length,
--                        Get_Name_String (Device_ASN1_Filename),
--                        Device_ASN1_Filename_Len,
--                        Get_Name_String (Device_ASN1_Typename),
--                        Device_ASN1_Typename_Len,
--                        Get_Name_String (Device_ASN1_Module),
--                        Device_ASN1_Module_Len);
--                    C_End_Device;
--                 end if;
--              end;
--           end if;
--
--           if Get_Category_Of_Component (Tmp_CI) = CC_Process then
--              declare
--                 Node_Coverage : Boolean := False;
--              begin
--                 if Is_Defined_Property (Tmp_CI,
--                                      "taste_dv_properties::coverageenabled")
--                 then
--                    Node_Coverage := Get_Boolean_Property
--                       (Tmp_CI,
--                   Get_String_Name ("taste_dv_properties::coverageenabled"));
--                    if Node_Coverage then
--                       Put_Line ("Needs Coverage");
--                    else
--                       Put_Line ("Needs No coverage");
--                    end if;
--                 end if;
--
--                 CPU := Get_Bound_Processor (Tmp_CI);
--                 Set_Str_To_Name_Buffer ("");
--                 CPU_Name := Name (Identifier (Parent_Subcomponent (CPU)));
--
--                 CPU_Platform := Get_Execution_Platform (CPU);
--
--                if ATN.Namespace (Corresponding_Declaration (CPU)) /= No_Node
--                 then
--                    Set_Str_To_Name_Buffer ("");
--                    Get_Name_String
--                       (ATN.Name
--                          (ATN.Identifier
--                             (ATN.Namespace
--                                (Corresponding_Declaration (CPU)))));
--                    Pkg_Name := Name_Find;
--                    C_Add_Package
--                       (Get_Name_String (Pkg_Name),
--                       Get_Name_String (Pkg_Name)'Length);
--                    Set_Str_To_Name_Buffer ("");
--                    Get_Name_String (Pkg_Name);
--                    Add_Str_To_Name_Buffer ("::");
--                    Get_Name_String_And_Append (Name (Identifier (CPU)));
--                    CPU_Classifier := Name_Find;
--                 else
--                    CPU_Classifier := Name (Identifier (CPU));
--                 end if;
--
--                 C_New_Processor
--                    (Get_Name_String (CPU_Name),
--                    Get_Name_String (CPU_Name)'Length,
--                    Get_Name_String (CPU_Classifier),
--                    Get_Name_String (CPU_Classifier)'Length,
--                    Supported_Execution_Platform'Image (CPU_Platform),
--                   Supported_Execution_Platform'Image (CPU_Platform)'Length);
--
--                 C_New_Process
--                    (Get_Name_String
--                       (ATN.Name
--                          (ATN.Component_Type_Identifier
--                             (Corresponding_Declaration (Tmp_CI)))),
--                     Get_Name_String
--                       (ATN.Name
--                          (ATN.Component_Type_Identifier
--                             (Corresponding_Declaration (Tmp_CI))))'Length,
--                    Get_Name_String (Name (Identifier (Processes))),
--                    Get_Name_String (Name (Identifier (Processes)))'Length,
--                    NodeName, NodeName'Length,
--                    Boolean'Pos (Node_Coverage));
--
--                 Processes2 := First_Node (Subcomponents (My_System));
--
--                 while Present (Processes2) loop
--                    Tmp_CI2 := Corresponding_Instance (Processes2);
--
--                    if Get_Category_Of_Component (Tmp_CI2) = CC_System
--                       and then
--                       Is_Defined_Property
--                          (Tmp_CI2, "taste::aplc_binding")
--                    then
--                       Ref := Get_Reference_Property
--                          (Tmp_CI2, Get_String_Name ("taste::aplc_binding"));
--
--                       if Ref = Tmp_CI then
--                          declare
--                             Bound_APLC_Name : Unbounded_String;
--                          begin
--                             begin
--                                Bound_APLC_Name := US
--                                  (Get_Name_String
--                                    (ATN.Name
--                                      (ATN.Component_Type_Identifier
--                                    (Corresponding_Declaration (Tmp_CI2)))));
--                             exception
--                                when System.Assertions.Assert_Failure =>
--                                   Put_Line
--                                      ("Detected DV from TASTE version 1.2");
--                                   Bound_APLC_Name := US
--                                     (Get_Name_String
--                                        (Name (Identifier (Processes2))));
--                             end;
--
--                             C_Add_Binding
--                                (To_String (Bound_APLC_Name),
--                                 To_String (Bound_APLC_Name)'Length);
--                          end;
--                       end if;
--                    end if;
--
--                    Processes2 := Next_Node (Processes2);
--                 end loop;
--
--                 C_End_Process;
--              end;
--           end if;
--
--           Processes := Next_Node (Processes);
--        end loop;
--        C_End_Drivers_Section;
--     end if;
   end Browse_Deployment_View_System;

   ------------------------
   -- Parse_Command_Line --
   ------------------------

   procedure Parse_Command_Line is
      FN                : Name_Id;
      B                 : Location;
      Previous_OutDir   : Boolean := False;
      Previous_IFview   : Boolean := False;
      Previous_CView    : Boolean := False;
      Previous_DataView : Boolean := False;
      Previous_Stack    : Boolean := False;
      Previous_TimerRes : Boolean := False;
   begin
      for J in 1 .. Ada.Command_Line.Argument_Count loop
         --  Parse the file corresponding to the Jth argument of the
         --  command line and enrich the global AADL tree.

         if Previous_IfView then
            Interface_View := J;
            Previous_Ifview := false;

         elsif Previous_Cview then
            Concurrency_view := J;
            Previous_Cview := false;

         elsif Previous_DataView then
            Data_View := J;
            Previous_DataView := false;

         elsif Previous_Outdir then
            OutDir := J;
            Previous_OutDir := false;

         elsif Previous_Stack then
            Stack_Val := J;
            Previous_Stack := false;

         elsif Previous_TimerRes then
            Timer_Resolution := J;
            Previous_TimerRes := false;

         elsif Ada.Command_Line.Argument (J) = "--polyorb-hi-c"
           or else Ada.Command_Line.Argument (J) = "-p"
           or else Ada.Command_Line.Argument (J) = "-polyorb-hi-c"
         then
            null;

         elsif Ada.Command_Line.Argument (J) = "--keep-case"
           or else Ada.Command_Line.Argument (J) = "-j"
           or else Ada.Command_Line.Argument (J) = "-keep-case"
         then
            Keep_case := true;

         elsif Ada.Command_Line.Argument (J) = "--glue"
           or else Ada.Command_Line.Argument (J) = "-glue"
           or else Ada.Command_Line.Argument (J) = "-l"
         then
            generate_glue := true;

         elsif Ada.Command_Line.Argument (J) = "--smp2"
           or else Ada.Command_Line.Argument (J) = "-m"
         then
            null;

         elsif Ada.Command_Line.Argument (J) = "--gw"
           or else Ada.Command_Line.Argument (J) = "-gw"
           or else Ada.Command_Line.Argument (J) = "-w"
         then
            null;

         --  The "test" flag activates a function in the parser,
         --  used for debugging purposes (e.g. dump of the model after
         --  all preprocessings). Users need not use it.
         elsif Ada.Command_Line.Argument (J) = "--test"
           or else Ada.Command_Line.Argument (J) = "-test"
           or else Ada.Command_Line.Argument (J) = "-t"
         then
            null;

         elsif Ada.Command_Line.Argument (J) = "--aadlv2"
           or else Ada.Command_Line.Argument (J) = "-aadlv2"
           or else Ada.Command_Line.Argument (J) = "-a"
         then
            AADL_Version := Ocarina.AADL_V2;

         elsif Ada.Command_Line.Argument (J) = "--future" then
            null;

         elsif Ada.Command_Line.Argument (J) = "--output"
           or else Ada.Command_Line.Argument (J) = "-o"
         then
            Previous_OutDir := True;

         elsif Ada.Command_Line.Argument (J) = "--interfaceview"
           or else Ada.Command_Line.Argument (J) = "-i"
         then
            Previous_Ifview := True;

         elsif Ada.Command_Line.Argument (J) = "--stack"
           or else Ada.Command_Line.Argument (J) = "-stack"
           or else Ada.Command_Line.Argument (J) = "-s"
         then
            Previous_Stack := True;

         elsif Ada.Command_Line.Argument (J) = "--timer"
           or else Ada.Command_Line.Argument (J) = "-timer"
           or else Ada.Command_Line.Argument (J) = "-x"
         then
            Previous_TimerRes := True;

         elsif Ada.Command_Line.Argument (J) = "--deploymentview"
           or else Ada.Command_Line.Argument (J) = "-c"
         then
            Previous_Cview := True;

         elsif Ada.Command_Line.Argument (J) = "--version"
           or else Ada.Command_Line.Argument (J) = "-v"
         then
            OS_Exit (0);

         elsif Ada.Command_Line.Argument (J) = "--dataview"
           or else Ada.Command_Line.Argument (J) = "-d"
         then
            Previous_DataView := True;

         elsif Ada.Command_Line.Argument (J) = "--debug"
           or else Ada.Command_Line.Argument (J) = "-g"
         then
            null;

         elsif Ada.Command_Line.Argument (J) = "--help"
           or else Ada.Command_Line.Argument (J) = "-h"
         then
            Usage;
            OS_Exit (0);

         else
            Set_Str_To_Name_Buffer (Ada.Command_Line.Argument (J));
            FN := Ocarina.Files.Search_File (Name_Find);
            Exit_On_Error (FN = No_Name, "File not found: "
                          & Ada.Command_Line.Argument (J));
            B := Ocarina.Files.Load_File (FN);
            Interface_Root := Ocarina.Parser.Parse
              (AADL_Language, Interface_Root, B);

            --  the "else" makes the parser parse any additional aadl files
            --  (in complement to the interface/deployment/data views)
            --  they must therefore be part of Root AND Deployment_Root trees
            Set_Str_To_Name_Buffer (Ada.Command_Line.Argument (J));
            FN := Ocarina.Files.Search_File (Name_Find);
            B := Ocarina.Files.Load_File (FN);
            Deployment_Root := Ocarina.Parser.Parse
              (AADL_Language, Deployment_Root, B);
         end if;
      end loop;
   end Parse_Command_Line;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
      FN : Name_Id;
      B  : Location;
   begin
      --  Initialization step: we look for ocarina on path to define
      --  OCARINA_PATH env. variable. This will indicate Ocarina librrary
      --  where to find AADL default property sets, and Ocarina specific
      --  packages and property sets.

      declare
         S : constant GNAT.OS_Lib.String_Access
           := GNAT.OS_Lib.Locate_Exec_On_Path ("ocarina");
      begin
         Exit_On_Error (S = null,
            "Ocarina is not in your PATH");
         GNAT.OS_Lib.Setenv ("OCARINA_PATH", S.all (S'First .. S'Last - 12));
      end;

      --  Display the command line syntax

      if Ada.Command_Line.Argument_Count = 0 then
         Usage;
         OS_Exit (1);
      end if;

      Ocarina.Initialize;
      Ocarina.AADL_Version := AADL_Version;

      Ocarina.Configuration.Init_Modules;
--      Ocarina.FE_AADL.Parser.First_Parsing := True;
      Ocarina.FE_AADL.Parser.Add_Pre_Prop_Sets := True;
      AADL_Language := Get_String_Name ("aadl");

      Parse_Command_Line;

      Exit_On_Error (Interface_View = 0, "Missing Interface view!");
      Set_Str_To_Name_Buffer (Ada.Command_Line.Argument (Interface_View));
      FN := Ocarina.Files.Search_File (Name_Find);
      Exit_On_Error (FN = No_Name, "Missing Interface view!");
      B := Ocarina.Files.Load_File (FN);
--     C_Set_Interfaceview
--      (Ada.Command_Line.Argument (Interface_View),
--       Ada.Command_Line.Argument (Interface_View)'Length);
      Interface_Root := Ocarina.Parser.Parse
        (AADL_Language, Interface_Root, B);

      if Concurrency_view = 0 and Generate_Glue then
         Put_Line ("Fatal error: Missing Deployment view!");
         Put_Line ("Use the '-c file.aadl' parameter.");
         Put_Line
            ("Note: the generation of glue code is invoked automatically");
         Put_Line
            ("from the TASTE orchestrator. You should run taste-aadl-parser");
         Put_Line
            ("only to generate your application skeletons ('-gw' flag).");
         New_line;

      elsif Concurrency_View > 0 and Generate_Glue then
         Set_Str_To_Name_Buffer (Ada.Command_Line.Argument (Concurrency_View));
         FN := Ocarina.Files.Search_File (Name_Find);
         B := Ocarina.Files.Load_File (FN);
         Deployment_Root := Ocarina.Parser.Parse
           (AADL_Language, Deployment_Root, B);
         Exit_On_Error (Deployment_Root = No_Node,
              "Deployment view is incorrect");
      end if;

      --  Missing data view is actually not an error.
      --  Systems can live with parameterless messages
      --  Exit_On_Error (Data_view = 0, "Error: Missing Data view!");
      if Data_View > 0 then
         Set_Str_To_Name_Buffer (Ada.Command_Line.Argument (Data_View));
         FN := Ocarina.Files.Search_File (Name_Find);

         Exit_On_Error (FN = No_Name, "Cannot find Data View");
--        C_Set_Dataview
--           (Ada.Command_Line.Argument (Data_View),
--           Ada.Command_Line.Argument (Data_View)'Length);
         B := Ocarina.Files.Load_File (FN);
         Interface_Root := Ocarina.Parser.Parse
           (AADL_Language, Interface_Root, B);
         if Deployment_Root /= No_Node then
            Deployment_Root := Ocarina.Parser.Parse
               (AADL_Language, Deployment_Root, B);
         end if;
         Dataview_root := Ocarina.Parser.Parse
                            (AADL_Language, Dataview_root, B);
      end if;

      Exit_On_Error (No (Interface_Root), "AADL Parser Internal error");

      --  Analyze the tree

      Success := Ocarina.Analyzer.Analyze (AADL_Language, Interface_Root);
      Exit_On_Error (not Success, "Cannot analyze model.");

   end Initialize;

   IV_Root : Node_Id;
   AST : Complete_Interface_View;

begin
   Banner;

   Initialize;

   --  First, we analyze the interface view. For that, we load the
   --  AADL model, analyze it. Under AADLv2 version, the root system
   --  of the interface view is called interfaceview.others.

   --  Instantiate AADL tree

   Ocarina.Options.Root_System_Name :=
          Get_String_Name ("interfaceview.others");

   IV_Root := Root_System (Instantiate_Model (Root => Interface_Root));
   AST := AADL_to_Ada_IV (IV_Root);

   Debug_Dump_IV (AST);

   --  Now, we are done with the interface view. We now analyze the
   --  deployment view.

   --  Additional properties for the Deployment view

   Load_Deployment_View_Properties (Deployment_Root);

   Process_Deployment_View (Deployment_Root);

   Ocarina.Configuration.Reset_Modules;
   Ocarina.Reset;
exception
   when Error : AADL_Parser_Error =>
      Put (Red_Bold & "[ERROR] " & White);
      Put_Line (Exception_Message (Error) & No_Color);
      OS_Exit (1);
   when E : others =>
      Errors.Display_Bug_Box (E);
end AADL_Parser;
