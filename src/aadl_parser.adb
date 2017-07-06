--  ************************ TASTE AADL Parser **************************  --
--  Based on Ocarina ****************************************************  --
--  (c) 2017 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file
pragma Warnings (Off);
with Ada.Strings.Unbounded,
     Ada.Characters.Handling,
     Ada.Command_Line,
     Ada.Text_IO,
     Ada.Containers.Indefinite_Vectors,
     GNAT.OS_Lib,
     Errors,
     Locations,
     Ocarina.Namet,
     Ocarina.Types,
     System.Assertions,
     Ocarina.Analyzer,
     Ocarina.Backends.Properties,
     Ocarina.Configuration,
     Ocarina.Files,
     Ocarina.Options,
     Ocarina.Instances,
     Ocarina.Instances.Queries,
     Ocarina.ME_AADL.AADL_Tree.Nodes,
     Ocarina.ME_AADL.AADL_Instances.Entities,
     Ocarina.ME_AADL.AADL_Instances.Nodes,
     Ocarina.ME_AADL.AADL_Instances.Nutils,
     Ocarina.Parser,
     Ocarina.FE_AADL.Parser,
     Parser_Utils,
     Ocarina.Backends.Utils;

use Ada.Strings.Unbounded,
    Ada.Text_IO,
    Ada.Characters.Handling,
    Locations,
    Ocarina.Namet,
    Ocarina.Types,
    Ocarina,
    Ocarina.Analyzer,
    Ocarina.Backends.Properties,
    Ocarina.Instances,
    Ocarina.Instances.Queries,
    Ocarina.ME_AADL,
    Ocarina.ME_AADL.AADL_Instances.Entities,
    Ocarina.ME_AADL.AADL_Instances.Nodes,
    Ocarina.ME_AADL.AADL_Instances.Nutils,
    Ocarina.Backends.Properties,
    Parser_Utils,
    GNAT.OS_Lib;

procedure AADL_Parser is

   package ATN renames Ocarina.ME_AADL.AADL_Tree.Nodes;

   AADL_Language : Name_Id;

   Interface_Root    : Node_Id := No_Node;
   Deployment_root   : Node_Id := No_Node;
   Dataview_root     : Node_ID := No_Node;
   Success           : Boolean;
   OutDir            : Integer := 0;
   Stack_Val         : Integer := 0;
   Timer_Resolution  : Integer := 0;
   Subs              : Node_id;
   Interface_view    : Integer := 0;
   Concurrency_view  : Integer := 0;
   Data_View         : Integer := 0;
   Generate_glue     : Boolean := false;
   Keep_case         : Boolean := false;
   AADL_Version      : AADL_Version_Type := Ocarina.AADL_V2;

   procedure Parse_Command_Line;
   procedure Process_Deployment_View (My_Root : Node_Id);
   --  procedure Process_DataView (My_Root : Node_Id);
   procedure Process_Interface_View (My_System : Node_Id);
   procedure Browse_Deployment_View_System
                  (My_System : Node_Id; NodeName : String);

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

   procedure Process_Interface_View (My_System : Node_Id) is
      Len_Name          : Integer;
      Len_Type          : Integer;
      Current_Function  : Node_Id;
      FV_Subco          : Node_Id;
      CI                : Node_Id;
      Connection_I      : Node_Id;
      Distant_FV        : Node_Id;
      If_I              : Node_Id;
      RI_To_Add         : Node_Id;
      Local_RI_Name     : Name_Id;
      Distant_PI_Name   : Name_Id;
      Param_I           : Node_Id;
      ASN1_Module       : Name_Id;
      ASN1_Filename     : Name_Id := No_Name;
      Operation_Kind    : Supported_RCM_Operation_Kind;
      Sub_I             : Node_Id;
      Encoding          : Supported_ASN1_Encoding;
      Asntype           : Node_Id;
      Basic_Type        : Supported_ASN1_Basic_Type;

   begin

      Exit_On_Error
         (No (My_System),
         "Internal Error, cannot instantiate model");

      if not Is_Empty (Subcomponents (My_System)) then
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
         Current_function := First_Node (Subcomponents (My_System));

         while Present (Current_Function) loop
            CI := Corresponding_Instance (Current_Function);

            if Get_Category_Of_Component (CI) = CC_System then

               --  Call C function "New_FV" and set the language
               --  Read the implementation language of the current
               --  FV from the Source_Language property

               declare
                  --  Read the name of the function
                  FV_Name_L : constant String := AIN_Lower (Current_Function);
                  FV_Name   : constant String := AIN_Case (Current_Function);
                  --  Read the source language
                  Source_Language : constant Supported_Source_Language :=
                      Get_Source_Language (CI);
                  --  To get the zipfile name where user code is stored
                  SourceText : constant Name_Array := Get_Source_Text (CI);
                  ZipId : Name_Id := No_Name;
               begin
--                C_New_FV (FV_Name_L, FV_Name'Length, FV_Name);

--                 case Source_Language is
--                    when Language_Ada_95        => C_Set_Language_To_Ada;
--                    when Language_C             => C_Set_Language_To_C;
--                    when Language_CPP           => C_Set_Language_To_CPP;
--                    when Language_VDM           => C_Set_Language_To_VDM;
--                    when Language_SDL_OpenGEODE => C_Set_Language_To_SDL;
--                    when Language_Scade         => C_Set_Language_To_Scade;
--                    when Language_Lustre        => C_Set_Language_To_Scade;
--                    when Language_SDL           => C_Set_Language_To_SDL;
--                    when Language_SDL_RTDS      => C_Set_Language_To_RTDS;
--                   when Language_Simulink      => C_Set_Language_To_Simulink;
--                   when Language_Rhapsody      => C_Set_Language_To_Rhapsody;
--                    when Language_Gui           => C_Set_Language_To_GUI;
--                    when Language_VHDL          => C_Set_Language_To_VHDL;
--                   when Language_System_C      => C_Set_Language_To_System_C;
--                    when Language_Device        =>
--                                           C_Set_Language_To_BlackBox_Device;
--                    when Language_QGenAda       => C_Set_Language_To_QGenAda;
--                    when Language_QGenC         => C_Set_Language_To_QGenC;
--                    when others                 => Exit_On_Error (True,
--                        "Language is currently not supported: "
--                        & Source_Language'Img);
--                 end case;

                  --  Retrieve the ZIP file (optionally set by the user)
                  if SourceText'Length /= 0 then
                     ZipId := SourceText (1);
                  end if;
--                 if ZipId /= No_Name then
--                    C_Set_Zipfile (Get_Name_String (ZipId),
--                                   Get_Name_String (ZipId)'Length);
--                 end if;
               end;

               --  Parse the functional states of this FV
               if not Is_Empty (Subcomponents (CI)) then
                  FV_Subco := First_Node (Subcomponents (CI));
                  while Present (FV_Subco) loop
                     if Get_Category_Of_Component (FV_Subco) = CC_Data
                     then
                        --  Check that the value of the FS is set
                        Exit_On_Error (Get_String_Property
                           (Corresponding_Instance (FV_Subco),
                              "taste::fs_default_value") = No_Name,
                           "Error: Missing value for context parameter " &
                           Get_Name_String
                              (Name (Identifier (FV_Subco))) &
                           " in function " & AIN_Case (Current_Function));
                        declare
                           --  Name of the variable
                           FS_name : constant String :=
                            Get_Name_String (Name (Identifier (FV_Subco)));
                           --  Name of the variable respecting case
                           FS_fullname : constant String :=
                            Get_Name_String (Display_Name (Identifier
                                (FV_Subco)));
                           --  ASN.1 type
                           Asn1type : constant Node_Id :=
                            Corresponding_Instance (FV_Subco);

                           FS_type : constant String :=
                                      Get_Name_String
                                          (Get_Type_Source_Name (Asn1type));
                           --  Variable default value
                           FS_value : constant String :=
                                  Get_Name_String (Get_String_Property
                                     (Asn1type, "taste::fs_default_value"));
                           FS_module : constant String :=
                                            Get_ASN1_Module_Name (Asn1type);
                           --  ASN.1 filename
                           NA : constant Name_Array :=
                                                 Get_Source_Text (Asn1type);
                           FS_File : Unbounded_String;
                        begin
                           --  Some special DATA components have no
                           --  Source_Text property in DataView.aadl
                           --  (TASTE-Directive and Tunable Parameter)
                           if NA'Length > 0 then
                              FS_File := US (Get_Name_String (NA (1)));
                           else
                              FS_File := US ("dummy");
                           end if;
--                          C_Set_Context_Variable
--                                           (FS_name, FS_name'Length,
--                                            FS_type, FS_type'Length,
--                                            FS_value, FS_value'Length,
--                                            FS_module, FS_module'Length,
--                                            To_String (FS_file),
--                                            To_String (FS_file)'Length,
--                                            FS_Fullname);
                        end;
                     end if;
                     FV_Subco := Next_Node (FV_Subco);
                  end loop;
               end if;

               --  Parse the interfaces of the FV
               if not Is_Empty (Features (CI)) then
                  If_I := First_Node (Features (CI));

                  while Present (If_I) loop
                     Sub_I := Get_RCM_Operation (If_I);

                     if Present (Sub_I) then
                        --  Call backend Add_PI or Add_RI and for each
                        --  parameter call C function Add_In_Param or
                        --  Add_Out_Param
                        if Is_Subprogram_Access (If_I) and
                                                   Is_Provided (If_I)
                        then
                           declare
                              PI_string : String :=
                               Get_Name_string
                                (Display_Name (Identifier (If_I)));
                              PI_Name : Name_Id;
                           begin
                              PI_Name := Get_Interface_Name (If_I);
--                             if PI_Name /= No_Name then
--                                C_Add_PI (Get_Name_String (PI_Name),
--                                         Get_Name_String (PI_Name)'Length);
--                             else
--                                --  Keep compatibility with V1.2
--                                if not Keep_case then
--                                   PI_string := to_lower (PI_string);
--                                end if;
--                                C_Add_PI (PI_String, PI_String'Length);
--                             end if;
                           end;

--                          if Kind (If_I) = K_Subcomponent_Access_Instance
--                             and then
--                             Is_Defined_Property
--                             (Corresponding_Instance (If_I),
--                             "taste::associated_queue_size")
--                          then
--                             C_Set_Interface_Queue_Size
--                                (Get_Integer_Property
--                                   (Corresponding_Instance (If_I),
--                                   "taste::associated_queue_size"));
--                          end if;

                           --  Set Provided Interface RCM kind
                           --  (cyclic, sporadic, etc).
                           Operation_Kind := Get_RCM_Operation_Kind (If_I);

 --                         case Operation_Kind is
 --                            when Cyclic_Operation =>
 --                               C_Set_Cyclic_IF;

 --                            when Sporadic_Operation | Any_Operation =>
 --                               C_Set_Sporadic_IF;

 --                            when Protected_Operation =>
 --                               C_Set_Protected_IF;

 --                            when Unprotected_Operation =>
 --                               C_Set_Unprotected_IF;
 --                         end case;

 --                         --  Set the period or MIAT of the PI
 --                         C_Set_Period (Get_RCM_Period (If_I));

                           --  Set the WCET of the PI
--                          if Is_Subprogram_Access (If_I) and then
--                             Sources (If_I) /= No_List and then
--                             First_Node (Sources (If_I)) /= No_Node
--                             and then
--                             Get_Execution_Time
--                                (Corresponding_Instance
--                                   (Item
--                                      (First_Node (Sources (If_I)))))
--                             /= Empty_Time_Array
--                          then
--                             null;
--                             declare
--                                use Ocarina.Backends.Utils;
--                                Exec_Time : constant Time_Array :=
--                                Get_Execution_Time
--                                   (Corresponding_Instance
--                                   (Item
--                                      (First_Node (Sources (If_I)))));
--                             begin
--                                null;
--                                C_Set_Compute_Time
--                                 (To_Milliseconds (Exec_Time (0)), "ms", 2,
--                                 To_Milliseconds (Exec_Time (1)), "ms", 2);
--                             end;
--                          else
--                             C_Set_Compute_Time (0, "ms", 2, 0, "ms", 2);
--                             --  Default !
--                           end if;

                        --   Required interface:
                        elsif Is_Subprogram_Access (If_I) and
                              not (Is_Provided (If_I))
                        then

                           --  the name of the feature (RI identifier) is:
                           --  Get_Name_String (Name (Identifier (If_I)));

                           --  Find the distant PI connected to this RI
                           --  and the distant function

                           Distant_Fv := No_Node;

                           if Present (Connections (My_System)) then
                              Connection_I := First_Node
                                 (Connections (My_System));
                           else
                              Connection_I := No_Node;
                           end if;

                           while Present (Connection_I) loop
                              if Corresponding_instance
                                (Get_Referenced_Entity
                                   (Source (Connection_I))) =
                                      Corresponding_Instance (If_I)
                              then
                                 Distant_FV := Item (First_Node
                                                     (Path
                                                      (Source
                                                       (Connection_I))));
                                 --  Get InterfaceName property if any
                                 Distant_PI_Name := Get_Interface_Name
                                       (Get_Referenced_Entity (
                                         Source (Connection_I)));
                                 --  Get RCM kind from remote PI
                                 Operation_Kind :=
                                       Get_RCM_Operation_Kind
                                          (Get_Referenced_Entity
                                              (Source (Connection_I)));
                              end if;
                              Connection_I := Next_Node (Connection_I);
                           end loop;
                           --  Found Distant PI name and distant function

                           RI_To_Add := Corresponding_Instance (If_I);
                           --  a RI can have a local name which is different
                           --  from the name of the PI it is connected to.
                           Local_RI_Name := Get_Interface_Name (If_I);
                           if Local_RI_Name = No_Name
                                   or Distant_PI_Name = No_Name
                           then
                              if Keep_case then
                                 Local_RI_Name :=
                                    Display_Name (Identifier (If_I));
                                 Distant_PI_Name :=
                                    Display_Name (Identifier (RI_To_Add));
                              else
                                 Local_RI_Name :=
                                    Name (Identifier (If_I));
                                 Distant_PI_Name :=
                                    Name (Identifier (RI_To_Add));
                              end if;
                           end if;
                           --   The 3 arguments to C_Add_RI are:
                           --   (1) the name of the local RI (feature)
                           --   (2) the name of the distant function
                           --   (3) the name of the corresponding PI
--                          if Present (Distant_FV) then
--                             C_Add_RI
--                                (Get_Name_String (Local_RI_Name),
--                                 Get_Name_String (Local_RI_Name)'Length,
--                                 Get_Name_String
--                                   (Name (Identifier (Distant_FV))),
--                                 Get_Name_String
--                                  (Name
--                                     (Identifier (Distant_FV)))'Length,
--                                 Get_Name_String (Distant_PI_Name),
--                                 Get_Name_String (Distant_PI_Name)'Length);
--                          else
--                             C_Add_RI
--                                (Get_Name_String (Local_RI_Name),
--                                 Get_Name_String (Local_RI_Name)'Length,
--                                 Get_Name_String (Local_RI_Name),
--                                 0,
--                                 Get_Name_String (Local_RI_Name),
--                                 Get_Name_String (Local_RI_Name)'Length);
--                          end if;

--                          case Operation_Kind is
--                             when Sporadic_Operation =>
--                                C_Set_ASync_IF;
--                                C_Set_Sporadic_IF;
--
--                             when Protected_Operation =>
--                                C_Set_Sync_IF;
--                                C_Set_Protected_IF;
--
--                             when Unprotected_Operation =>
--                                C_Set_Sync_IF;
--                                C_Set_Unprotected_IF;
--
--                             when others =>
--                                Exit_On_Error (True,
--                                           "Unsupported kind of RI: "
--                                          & Get_Name_String (Local_RI_Name));
--                          end case;
                        end if;

                        --  Parse the list of parameters

                        if not Is_Empty (Features (Sub_I)) then
                           Param_I := First_Node (Features (Sub_I));

                           while Present (Param_I) loop
                              if Kind (Param_I) = K_Parameter_Instance then
                                 Asntype := Corresponding_Instance
                                    (Param_I);

                                 declare
                                    NA : constant Name_Array
                                       := Get_Source_Text (Asntype);
                                 begin
                                    ASN1_Filename := NA (1);
                                 end;

                                 Exit_On_Error
                                   (ASN1_Filename = No_Name,
                                    "Error: Source_Text not defined");

                                 Len_Name := Get_Name_String
                                   (Name (Identifier (Param_I)))'Length;
                                 Len_Type := Get_Name_String
                                   (Name (Identifier (Asntype)))'Length;
                                 ASN1_Module := Get_Ada_Package_Name
                                    (Asntype);
                                 Exit_On_Error
                                   (ASN1_Module = No_Name,
                                    "Error: Data Model is incorrect.");

--                                if Is_In (Param_I) then
--                                   C_Add_In_Param
--                                     (Get_Name_String
--                                        (Display_Name
--                                            (Identifier (Param_I))),
--                                      Len_Name,
--                                      Get_Name_String
--                                        (Get_Type_Source_Name (Asntype)),
--                                      Len_Type,
--                                      Get_Name_String (ASN1_Module),
--                                      Get_Name_String
--                                         (ASN1_Module)'Length,
--                                      Get_Name_String (ASN1_Filename),
--                                      Get_Name_String
--                                         (ASN1_Filename)'Length);
--                                else
--                                   C_Add_Out_Param
--                                     (Get_Name_String
--                                        (Display_Name
--                                            (Identifier (Param_I))),
--                                      Len_Name,
--                                      Get_Name_String
--                                        (Get_Type_Source_Name (Asntype)),
--                                      Len_Type,
--                                      Get_Name_String (ASN1_Module),
--                                      Get_Name_String
--                                         (ASN1_Module)'Length,
--                                      Get_Name_String (ASN1_Filename),
--                                      Get_Name_String
--                                         (ASN1_Filename)'Length);
--                                end if;

                                 --  Get the Encoding property:

--                                Encoding := Get_ASN1_Encoding (Param_I);
--                                case Encoding is
--                                   when Native => C_Set_Native_Encoding;
--                                   when UPER   => C_Set_UPER_Encoding;
--                                   when ACN    => C_Set_ACN_Encoding;
--                                   when others => null;
--                                end case;

                                 --  Get ASN.1 basic type of the parameter
                                 Basic_type := Get_ASN1_Basic_Type
                                    (Asntype);
--                                case Basic_Type is
--                                   pragma Style_Checks (Off);
--                                   when Asn1_Sequence =>
--                                      C_Set_ASN1_BasicType_Sequence;
--                                   when ASN1_SequenceOf =>
--                                      C_Set_ASN1_BasicType_SequenceOf;
--                                   when ASN1_Enumerated =>
--                                      C_Set_ASN1_BasicType_Enumerated;
--                                   when ASN1_Set =>
--                                      C_Set_ASN1_BasicType_Set;
--                                   when ASN1_SetOf =>
--                                      C_Set_ASN1_BasicType_SetOf;
--                                   when ASN1_Integer =>
--                                      C_Set_ASN1_BasicType_Integer;
--                                   when ASN1_Boolean =>
--                                      C_Set_ASN1_BasicType_Boolean;
--                                   when ASN1_Real =>
--                                      C_Set_ASN1_BasicType_Real;
--                                   when ASN1_OctetString =>
--                                      C_Set_ASN1_BasicType_OctetString;
--                                   when ASN1_Choice =>
--                                      C_Set_ASN1_BasicType_Choice;
--                                   when ASN1_String =>
--                                      C_Set_ASN1_BasicType_String;
--                                   when others =>
--                                      C_Set_ASN1_BasicType_Unknown;
--                                      pragma Style_Checks (On);
--                                end case;
                              end if;

                              Param_I := Next_Node (Param_I);
                           end loop;
                        end if; -- End processing parameters.
                     end if;

                     If_I := Next_Node (If_I);
                  end loop; -- Go to next interface of this FV

               end if;
            end if;
            Current_Function := Next_Node (Current_Function);
         end loop;
      end if;
   end Process_Interface_View;

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
--        Exit_On_Error (not Success, "[ERROR] Deployment view is incorrect");
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
      Processes         : Node_Id;
      Processes2        : Node_Id;
      Tmp_CI            : Node_Id;
      Tmp_CI2           : Node_Id;
      Ref               : Node_Id;
      CPU               : Node_Id;
      CPU_Name          : Name_Id := No_Name;
      Pkg_Name          : Name_Id := No_Name;
      CPU_Classifier    : Name_Id := No_Name;
      CPU_Platform      : Supported_Execution_Platform := Platform_None;
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
--                            "[ERROR] Device configuration is incorrect (" &
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
            null;

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
            "[ERROR] ocarina is not in your PATH");
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

      Exit_On_Error (Interface_View = 0, "Error: Missing Interface view!");
      Set_Str_To_Name_Buffer (Ada.Command_Line.Argument (Interface_View));
      FN := Ocarina.Files.Search_File (Name_Find);
      Exit_On_Error (FN = No_Name, "Error: Missing Interface view!");
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
              "[ERROR] Deployment view is incorrect");
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

      Exit_On_Error (No (Interface_Root), "Internal error");

      --  Analyze the tree

      Success := Ocarina.Analyzer.Analyze (AADL_Language, Interface_Root);
      Exit_On_Error (not Success, "Internal Error, cannot analyze model.");

   end Initialize;

   IV_Root : Node_Id;
   AST : Complete_Interface_View;
   pragma Unreferenced (AST);

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
   --  AST := AADL_to_Ada_IV (IV_Root);
   --  for each of AST.Flat_Functions loop
   --     Put_Line ("AST: " & To_String (Each.Prefix.Value_Or (US ("")))
   --                 & " " & To_String (Each.Name));
   --  end loop;

   Process_Interface_View (IV_Root);
--      (Root_System (Instantiate_Model (Root => Interface_Root)));

   --  Now, we are done with the interface view. We now analyze the
   --  deployment view.

   --  Additional properties for the Deployment view

   Load_Deployment_View_Properties (Deployment_Root);

   Process_Deployment_View (Deployment_Root);

   Ocarina.Configuration.Reset_Modules;
   Ocarina.Reset;
exception
   when E : others =>
      Errors.Display_Bug_Box (E);
end AADL_Parser;
