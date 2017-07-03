--  *************************** buildsupport ****************************  --
--  (c) 2008-2017 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

with Ada.Text_IO,
     GNAT.OS_Lib,
     Buildsupport_Version,
     Ocarina.Configuration,
     Ocarina.AADL_Values,
     Ocarina.Instances.Queries,
     Ocarina.ME_AADL.AADL_Instances.Nutils,
     Ocarina.ME_AADL.AADL_Instances.Entities,
     Ocarina.Backends.Utils,
     Ada.Characters.Latin_1;

package body Buildsupport_Utils is

   use Ada.Text_IO,
       GNAT.OS_Lib,
       Ocarina.Instances.Queries,
       Ocarina.ME_AADL.AADL_Instances.Nutils,
       Ada.Characters.Latin_1,
       Ocarina.ME_AADL.AADL_Instances.Entities,
       Ocarina.ME_AADL,
       Ocarina.Backends.Utils;

   ------------
   -- Banner --
   ------------

   procedure Banner is
      The_Banner : constant String :=
        "TASTE Buildsupport (Version "
        & Buildsupport_Version.Buildsupport_Release & ") "
        & ASCII.LF & ASCII.CR
        & "Contact: Maxime.Perrotin@esa.int or Thanassis.Tsiodras@esa.int"
        & ASCII.LF & ASCII.CR
        & "Based on Ocarina: " & Ocarina.Configuration.Ocarina_Version;
   begin
      Put_Line (The_Banner);
   end Banner;

   -----------
   -- Usage --
   -----------

   procedure Usage is
   begin
      Put_Line
        ("Usage: buildsupport <options> otherfiles");
      Put_Line
        ("Where <options> are:");
      New_Line;
      Put ("-l, --glue" & HT & HT & HT & HT);
      Put_Line ("Generate glue code");
      Put ("-w, --gw" & HT & HT & HT & HT);
      Put_Line ("Generate code skeletons");
      Put ("-j, --keep-case" & HT & HT & HT & HT);
      Put_Line ("Respect the case for interface names");
      Put ("-o, --output <outputDir>" & HT & HT);
      Put_Line ("Root directory for the output files");
      Put ("-i, --interfaceview <i_view.aadl>" & HT);
      Put_Line ("The interface view in AADL");
      Put ("-c, --deploymentview <d_view.aadl>" & HT);
      Put_Line ("The deployment view in AADL");
      Put ("-d, --dataview <dataview.aadl>" & HT & HT);
      Put_Line ("The data view in AADL");
      Put ("-t, --test" & HT & HT & HT & HT);
      Put_Line ("Dump model information");
      Put ("-g, --debug" & HT & HT & HT & HT);
      Put_Line ("Generate runtime debug output");
      Put ("-s, --stack <stack-value>" & HT & HT);
      Put_Line ("Set the size of the stack per thread in kbytes (default 50)");
      Put ("-x, --timer <timer-resolution in ms>" & HT);
      Put_Line ("Set the timer resolution (default 100 ms)");
      Put ("-v, --version" & HT & HT & HT & HT);
      Put_Line ("Display buildsupport version number");
      Put ("-p, --polyorb-hi-c" & HT & HT & HT);
      Put_Line ("Interface glue code with PolyORB-HI-C");
      Put ("otherfiles" & HT & HT & HT & HT);
      Put_Line ("Any other aadl file you want to parse");
      New_Line;
      New_Line;
      Put_Line ("For example, this command will generate your application"
       & " skeletons:");
      New_Line;
      Put_Line ("buildsupport -i InterfaceView.aadl -d DataView.aadl"
       & " -o code --gw --keep-case");
      New_Line;

   end Usage;

   -------------------
   -- Exit_On_Error --
   -------------------

   procedure Exit_On_Error (Error : Boolean; Reason : String) is
   begin
      if Error then
         Put_Line (Reason);
         OS_Exit (1);
      end if;
   end Exit_On_Error;

   ----------------------------
   -- Get_RCM_Operation_Kind --
   ----------------------------

   function Get_RCM_Operation_Kind
     (E : Node_Id) return Supported_RCM_Operation_Kind
   is
      RCM_Operation_Kind_N : Name_Id;
      RCM_Operation_Kind : constant Name_Id :=
          Get_String_Name ("taste::rcmoperationkind");
      Unprotected_Name   : constant Name_Id := Get_String_Name ("unprotected");
      Protected_Name     : constant Name_Id := Get_String_Name ("protected");
      Cyclic_Name        : constant Name_Id := Get_String_Name ("cyclic");
      Sporadic_Name      : constant Name_Id := Get_String_Name ("sporadic");
      Any_Name           : constant Name_Id := Get_String_Name ("any");
   begin
      if Is_Defined_Enumeration_Property (E, RCM_Operation_Kind) then
         RCM_Operation_Kind_N :=
            Get_Enumeration_Property (E, RCM_Operation_Kind);

         if RCM_Operation_Kind_N = Unprotected_Name then
            return Unprotected_Operation;

         elsif RCM_Operation_Kind_N =  Protected_Name then
            return Protected_Operation;

         elsif RCM_Operation_Kind_N =  Cyclic_Name then
            return Cyclic_Operation;

         elsif RCM_Operation_Kind_N =  Sporadic_Name then
            return Sporadic_Operation;

         elsif RCM_Operation_Kind_N =  Any_Name then
            return Any_Operation;
         end if;
      end if;
      Exit_On_Error (True, "Could not determine interface kind: "
                        & Get_Name_String (RCM_Operation_Kind_N));
      return Sporadic_Operation;
   end Get_RCM_Operation_Kind;

   -----------------------
   -- Get_RCM_Operation --
   -----------------------

   function Get_RCM_Operation (E : Node_Id) return Node_Id is
      RCM_Operation : constant Name_Id :=
          Get_String_Name ("taste::rcmoperation");
   begin
      if Is_Subprogram_Access (E) then
         return Corresponding_Instance (E);
      else
         if Is_Defined_Property (E, RCM_Operation) then
            return Get_Classifier_Property (E, RCM_Operation);
         else
            return No_Node;
         end if;
      end if;
   end Get_RCM_Operation;

   -----------------------
   -- Get_APLC_Binding --
   -----------------------

   function Get_APLC_Binding (E : Node_Id) return List_Id is
      APLC_Binding : constant Name_Id :=
          Get_String_Name ("taste::aplc_binding");
   begin
      if Is_Defined_Property (E, APLC_Binding) then
         return Get_List_Property (E, APLC_Binding);
      else
         return No_List;
      end if;
   end Get_APLC_Binding;

   --------------------
   -- Get_RCM_Period --
   --------------------

   function Get_RCM_Period (D : Node_Id) return Unsigned_Long_Long is
      RCM_Period : constant Name_Id := Get_String_Name ("taste::rcmperiod");
   begin
      if Is_Defined_Integer_Property (D, RCM_Period) then
         return Get_Integer_Property (D, RCM_Period);
      else
         return 0;
      end if;
   end Get_RCM_Period;

   --------------------------
   -- Get_Ada_Package_Name --
   --------------------------

   function Get_Ada_Package_Name (D : Node_Id) return Name_Id is
      Ada_Package_Name : constant Name_id :=
         Get_String_Name ("taste::ada_package_name");
   begin
      return Get_String_Property (D, Ada_Package_Name);
   end Get_Ada_Package_Name;

   -------------------------------
   -- Get_Ellidiss_Tool_Version --
   -------------------------------

   function Get_Ellidiss_Tool_Version (D : Node_Id) return Name_Id is
      Ellidiss_Tool_Version : constant Name_id :=
         Get_String_Name ("taste::version");
   begin
      return Get_String_Property (D, Ellidiss_Tool_Version);
   end Get_Ellidiss_Tool_Version;

   ------------------------
   -- Get_Interface_Name --
   ------------------------

   function Get_Interface_Name (D : Node_Id) return Name_Id is
      Interface_Name : constant Name_id :=
         Get_String_Name ("taste::interfacename");
   begin
      return Get_String_Property (D, Interface_Name);
   end Get_Interface_Name;

   ---------------------------
   -- Get ASN.1 Module name --
   ---------------------------

   function Get_ASN1_Module_Name (D : Node_Id) return String is
      id : Name_Id := No_Name;
      ASN1_Module : constant Name_id :=
         Get_String_Name ("deployment::asn1_module_name");
   begin
      if Is_Defined_String_Property (D, ASN1_Module) then
         id := Get_String_Property (D, ASN1_Module);
         return Get_Name_String (id);
      else
         return Get_Name_String (Get_String_Name ("nomodule"));
      end if;
   end Get_ASN1_Module_Name;

   --------------------------------------------
   -- Get all properties as a Map Key/String --
   -- Input parameter is an AADL instance    --
   --------------------------------------------
   function Get_Properties_Map (D : Node_Id) return Property_Maps.Map is
      properties : constant List_Id  := AIN.Properties (D);
      result     : Property_Maps.Map := Property_Maps.Empty_Map;
      property   : Node_Id           := AIN.First_Node (properties);
      prop_value : Node_Id;
      single_val : Node_Id;
   begin
      while Present (property) loop
         prop_value := AIN.Property_Association_Value (property);
         if Present (ATN.Single_Value (prop_value)) then
            --  Only support single-value properties for now
            single_val := ATN.Single_Value (prop_value);
            result.Insert (Key => AIN_Case (property),
                        New_Item =>
              (case ATN.Kind (single_val) is
                 when ATN.K_Signed_AADLNumber =>
                   Ocarina.AADL_Values.Image
                      (ATN.Value (ATN.Number_Value (single_val))) &
                      (if Present (ATN.Unit_Identifier (single_val)) then " " &
                      Get_Name_String
                          (ATN.Display_Name (ATN.Unit_Identifier (single_val)))
                      else ""),
                 when ATN.K_Literal =>
                    Ocarina.AADL_Values.Image (ATN.Value (single_val),
                                               Quoted => False),
                 when ATN.K_Reference_Term =>
                    Get_Name_String
                       (ATN.Display_Name (ATN.First_Node --  XXX must iterate
                          (ATN.List_Items (ATN.Reference_Term (single_val))))),
                 when ATN.K_Enumeration_Term =>
                    Get_Name_String
                       (ATN.Display_Name (ATN.Identifier (single_val))),
                 when ATN.K_Number_Range_Term =>
                    "RANGE NOT SUPPORTED!",
                 when others => "ERROR! Unsupported kind: "
                                & ATN.Kind (single_val)'Img));
         end if;
         property := AIN.Next_Node (property);
      end loop;
      return result;
   end Get_Properties_Map;

   -----------------------
   -- Get_ASN1_Encoding --
   -----------------------

   function Get_ASN1_Encoding (E : Node_Id) return Supported_ASN1_Encoding is
      ASN1_Encoding_N : Name_Id;
      ASN1_Encoding : constant Name_Id := Get_String_Name ("taste::encoding");
      Native_Name   : constant Name_Id := Get_String_Name ("native");
      UPER_Name     : constant Name_Id := Get_String_Name ("uper");
      ACN_Name      : constant Name_Id := Get_String_Name ("acn");
   begin
      if Is_Defined_Enumeration_Property (E, ASN1_Encoding) then
         ASN1_Encoding_N := Get_Enumeration_Property (E, ASN1_Encoding);

         if ASN1_Encoding_N = Native_Name then
            return Native;

         elsif ASN1_Encoding_N = UPER_Name then
            return UPER;

         elsif ASN1_Encoding_N = ACN_Name then
            return ACN;
         end if;
      end if;
      Exit_On_Error (True, "ASN1 Encoding not set");
      return Default;
   end Get_ASN1_Encoding;

   -------------------------
   -- Get_ASN1_Basic_Type --
   -------------------------

   function Get_ASN1_Basic_Type (E : Node_Id) return Supported_ASN1_Basic_Type
   is
      ASN1_Basic_Type  : constant Name_Id :=
                               Get_String_Name ("taste::asn1_basic_type");
      Sequence_Name    : constant Name_Id := Get_String_Name ("asequence");
      SequenceOf_Name  : constant Name_Id := Get_String_Name ("asequenceof");
      Enumerated_Name  : constant Name_Id := Get_String_Name ("aenumerated");
      Set_Name         : constant Name_Id := Get_String_Name ("aset");
      SetOf_Name       : constant Name_Id := Get_String_Name ("asetof");
      Integer_Name     : constant Name_Id := Get_String_Name ("ainteger");
      Boolean_Name     : constant Name_Id := Get_String_Name ("aboolean");
      Real_Name        : constant Name_Id := Get_String_Name ("areal");
      OctetString_Name : constant Name_Id := Get_String_Name ("aoctetstring");
      Choice_Name      : constant Name_Id := Get_String_Name ("achoice");
      String_Name      : constant Name_Id := Get_String_Name ("astring");
      ASN1_Basic_Type_N : Name_Id;
   begin
      if Is_Defined_Enumeration_Property (E, ASN1_Basic_Type) then
         ASN1_Basic_Type_N := Get_Enumeration_Property (E, ASN1_Basic_Type);

         if ASN1_Basic_Type_N = Sequence_Name then
            return ASN1_Sequence;

         elsif ASN1_Basic_Type_N = SequenceOf_Name then
            return ASN1_SequenceOf;

         elsif ASN1_Basic_Type_N = Enumerated_Name then
            return ASN1_Enumerated;

         elsif ASN1_Basic_Type_N = Set_Name then
            return ASN1_Set;

         elsif ASN1_Basic_Type_N = SetOf_Name then
            return ASN1_SetOf;

         elsif ASN1_Basic_Type_N = Integer_Name then
            return ASN1_Integer;

         elsif ASN1_Basic_Type_N = Boolean_Name then
            return ASN1_Boolean;

         elsif ASN1_Basic_Type_N = Real_Name then
            return ASN1_Real;

         elsif ASN1_Basic_Type_N = OctetString_Name then
            return ASN1_OctetString;

         elsif ASN1_Basic_Type_N = Choice_Name then
            return ASN1_Choice;

         elsif ASN1_Basic_Type_N = String_Name then
            return ASN1_String;

         else
            raise Program_Error with "Undefined choice "
              & Get_Name_String (ASN1_Basic_Type_N);
         end if;
      end if;
      Exit_On_Error (True, "Error: ASN.1 Basic type undefined!");
      return ASN1_Unknown;
   end Get_ASN1_Basic_Type;

   ----------------------------------------------------------------
   -- Get Optional Worse Case Execution Time (Upper bound in ms) --
   ----------------------------------------------------------------

   function Get_Upper_WCET (Func : Node_Id) return Optional_Long_Long is
      (if Is_Subprogram_Access (Func) and then Sources (Func) /= No_List
         and then AIN.First_Node (Sources (Func)) /= No_Node
         and then Get_Execution_Time (Corresponding_Instance (AIN.Item
                                           (AIN.First_Node (Sources (Func)))))
                           /= Empty_Time_Array
      then Just (To_Milliseconds (Get_Execution_Time (Corresponding_Instance
                             (AIN.Item (AIN.First_Node (Sources (Func)))))(1)))
         else Nothing);

   ---------------------------
   -- AST Builder Functions --
   ---------------------------

   function AADL_to_Ada_IV (System : Node_Id) return Complete_Interface_View is
      use type Functions.Vector;
      use type Channels.Vector;
      use type Ctxt_Params.Vector;
      use type Interfaces.Vector;
      use type Parameters.Vector;
      use type Connection_Maps.Map;
      Funcs             : Functions.Vector := Functions.Empty_Vector;
      Routes            : Channels.Vector; --  := Channels.Empty_Vector;
      Routes_Map        : Connection_Maps.Map;
      Current_Function  : Node_Id;

      --  Parse a connection
      function Parse_Connection (Conn : Node_Id) return Connection is
         Caller  : constant Node_Id := AIN.Item (AIN.First_Node
                                         (AIN.Path (AIN.Destination (Conn))));
         Callee  : constant Node_Id := AIN.Item (AIN.First_Node
                                         (AIN.Path (AIN.Source (Conn))));
         PI_Name : constant Name_Id := Get_Interface_Name
                                   (Get_Referenced_Entity (AIN.Source (Conn)));
         RI_Name : constant Name_Id := Get_Interface_Name
                              (Get_Referenced_Entity (AIN.Destination (Conn)));
      begin
         --  Put_Line (AIN.Node_Kind'Image (Kind (Caller)));
         return Connection'(Caller =>
           (if Kind (Caller) = K_Subcomponent_Access_Instance then US ("_env")
            else US (AIN_Case (Caller))),
                            Callee =>
           (if Kind (Callee) = K_Subcomponent_Access_Instance then US ("_env")
            else US (AIN_Case (Callee))),
                            PI_Name => US (Get_Name_String (PI_Name)),
                            RI_Name => US (Get_Name_String (RI_Name)));
      end Parse_Connection;

      --  Create a vector of connections for a given system
      --  This vector will then be filtered to connect end-to-end functions
      --  once the system is flattened
      function Parse_System_Connections (System : Node_Id)
         return Channels.Vector
      is
         Conn   : Node_Id;
         Result : Channels.Vector;
      begin
         if Present (AIN.Connections (System)) then
            Conn := AIN.First_Node (AIN.Connections (System));
            while Present (Conn) loop
               Result := Result & Parse_Connection (Conn);
               Conn := AIN.Next_Node (Conn);
            end loop;
         end if;
         return Result;
      end Parse_System_Connections;

      --  Parse an individual context parameter
      function Parse_CP (Subco : Node_Id) return Context_Parameter is
         CP_ASN1 : constant Node_Id    := Corresponding_Instance (Subco);
         NA      : constant Name_Array := Get_Source_Text (CP_ASN1);
      begin
         return Context_Parameter'(
            Name           => US (AIN_Case (Subco)),
            Sort           => US (Get_Name_String
                                        (Get_Type_Source_Name (CP_ASN1))),
            Default_Value  => US (Get_Name_String (Get_String_Property
                                        (CP_ASN1, "taste::fs_default_value"))),
            ASN1_Module    => US (Get_ASN1_Module_Name (CP_ASN1)),
            ASN1_File_Name => (if NA'Length > 0 then
                               Just (US (Get_Name_String (NA (1))))
                               else Nothing));
      end Parse_CP;

      --  Parse a single parameter of an interface
      --  * Name                (Unbounded string)
      --  * Sort                (Unbounded string)
      --  * ASN1_Module         (Unbounded string)
      --  * ASN1_Basic_Type     (Supported_ASN1_Basic_Type)
      --  * ASN1_File_Name      (Unbounded string)
      --  * Encoding            (Supported_ASN1_Encoding)
      --  * Direction           (Parameter_Direction: IN or OUT)
      function Parse_Parameter (Param_I : Node_Id) return ASN1_Parameter is
         Asntype : constant Node_Id := Corresponding_Instance (Param_I);
      begin
         return ASN1_Parameter'(
             Name => US (AIN_Case (Param_I)),
             Sort => US (Get_Name_String (Get_Type_Source_Name (Asntype))),
             ASN1_Module =>
                 US (Get_Name_String (Get_Ada_Package_Name (Asntype))),
             ASN1_Basic_Type => Get_ASN1_Basic_Type (Asntype),
             ASN1_File_Name =>
                US (Get_Name_String (Get_Source_Text (Asntype)(1))),
             Encoding => Get_ASN1_Encoding (Param_I),
             Direction => (if AIN.Is_In (Param_I)
                           then param_in else param_out));
      end Parse_Parameter;

      --  Parse a function interface :
      --  * Name                (Unbounded string)
      --  * Params              (Parameters.Vector)
      --  * RCM                 (Supported_RCM_Operation_Kind)
      --  * Period_Or_MIAT      (Unsigned long long)
      --  * WCET_ms             (Optional unsigned long long)
      --  * Queue_Size          (Optional unsigned long long)
      --  * User_Properties     (Property_Maps.Map)
      function Parse_Interface (If_I : Node_Id) return Taste_Interface is
         Name    : constant Name_Id := Get_Interface_Name (If_I);
         CI      : constant Node_Id := Corresponding_Instance (If_I);
         Result  : Taste_Interface;
         Sub_I   : constant Node_Id := Get_RCM_Operation (If_I);
         Param_I : Node_Id;
      begin
         pragma Assert (Present (Sub_I));
         --  Keep compatibility with 1.2 models for the interface name
         Result.Name := (if Name = No_Name then US (AIN_Case (If_I)) else
                         US (Get_Name_String (Name)));
         Result.Queue_Size := (if Kind (If_I) = K_Subcomponent_Access_Instance
                               and then Is_Defined_Property
                                   (CI, "taste::associated_queue_size")
                               then Just (Get_Integer_Property
                                   (CI, " taste::associated_queue_size"))
                               else Nothing);
         Result.RCM := Get_RCM_Operation_Kind (If_I);
         Result.Period_Or_MIAT := Get_RCM_Period (If_I);
         Result.WCET_ms := Get_Upper_WCET (If_I);
         Result.User_Properties := Get_Properties_Map (If_I);
         --  Parameters:
         if not Is_Empty (AIN.Features (Sub_I)) then
            Param_I := AIN.First_Node (AIN.Features (Sub_I));
            while Present (Param_I) loop
               if Kind (Param_I) = K_Parameter_Instance then
                  Result.Params := Result.Params & Parse_Parameter (Param_I);
               end if;
               Param_I := AIN.Next_Node (Param_I);
            end loop;
         end if;
         return Result;
      end Parse_Interface;

      --  Parse the content of a single function :
      --  * Name
      --  * Language
      --  * Zip File
      --  * Context Parameters
      --  * User Properties (from TASTE_IV_Properties.aadl)
      --  * Timers
      --  * Provided and Required Interfaces
      function Parse_Function (Prefix : String;
                               Name   : String;
                               Inst   : Node_Id) return Taste_Terminal_Function
      is
         Result      : Taste_Terminal_Function;
         --  To get the optional zip filename where user code is stored:
         Source_Text : constant Name_Array := Get_Source_Text (Inst);
         Zip_Id      : Name_Id             := No_Name;
         --  To get the context parameters
         Subco       : Node_Id;
         --  To get the provided and required interfaces
         PI_Or_RI    : Node_Id;
      begin
         Result.Name     := US (Name);
         Result.Prefix   := (if Prefix'Length > 0 then Just (US (Prefix))
                             else Nothing);
         Result.Language := Get_Source_Language (Inst);
         if Source_Text'Length /= 0 then
            Zip_Id          := Source_Text (1);
            Result.Zip_File := Just (US (Get_Name_String (Zip_Id)));
         end if;
         --  Parse context parameters
         if Present (AIN.Subcomponents (Inst)) then
            Subco := AIN.First_Node (AIN.Subcomponents (Inst));
            while Present (Subco) loop
               case Get_Category_Of_Component (Subco) is
                  when CC_Data =>
                     Result.Context_Params := Result.Context_Params
                                              & Parse_CP (Subco);
                  when others =>
                     null;
               end case;
               Subco := AIN.Next_Node (Subco);
            end loop;
         end if;
         --  Parse provided and required interfaces
         if Present (AIN.Features (Inst)) then
            PI_Or_RI := AIN.First_Node (AIN.Features (Inst));
            while Present (PI_Or_RI) loop
               if AIN.Is_Provided (PI_Or_RI) then
                  Result.Provided := Result.Provided
                                        & Parse_Interface (PI_Or_RI);
               else
                  Result.Required := Result.Required
                                        & Parse_Interface (PI_Or_RI);
               end if;
               PI_Or_RI := AIN.Next_Node (PI_Or_RI);
            end loop;
         end if;
         Result.User_Properties := Get_Properties_Map (Inst);
         return Result;
      end Parse_Function;

      --  Recursive parsing of a system made of nested functions (TASTE v2)
      function Rec_Function (Prefix : String := "";
                             Func   : Node_Id) return Functions.Vector is
         Inner        : Node_Id;
         Res          : Functions.Vector := Functions.Empty_Vector;
         CI           : constant Node_Id := Corresponding_Instance (Func);
         Name         : constant String := AIN_Case (Func);
         Next_Prefix  : constant String := Prefix &
                           (if Prefix'Length > 0 then "." else "") & Name;
      begin

         case Get_Category_Of_Component (CI) is
            when CC_System =>
               if Present (AIN.Subcomponents (CI)) then
                  Inner := AIN.First_Node (AIN.Subcomponents (CI));
                  while Present (Inner) loop
                     Res := Res & Rec_Function (Prefix => Next_Prefix,
                                                Func   => Inner);
                     Inner := AIN.Next_Node (Inner);
                  end loop;
               end if;

               --  Routes := Routes & Parse_System_Connections (CI);
               Routes_Map.Insert (Key      => Name,
                                  New_Item => Parse_System_Connections (CI));

               if No (AIN.Subcomponents (CI)) or Res = Functions.Empty_Vector
               then
                  Res := Res & Parse_Function (Prefix => Prefix,
                                               Name   => Name,
                                               Inst   => CI);
               end if;
            when others =>
               null;
         end case;

         return Res;
      end Rec_Function;
   begin
      Exit_On_Error (No (System), "Missing or erroneous interface view");

      Current_Function := AIN.First_Node (AIN.Subcomponents (System));
      --  Parse functions
      while Present (Current_Function) loop
         Funcs := Funcs & Rec_Function (Func => Current_Function);
         Current_Function := AIN.Next_Node (Current_Function);
      end loop;

      Routes_Map.Insert (Key      => "_Root",
                         New_Item => Parse_System_Connections (System));
      for C in Routes_Map.Iterate loop
         Put_Line ("Routes of Function " & Connection_Maps.Key (C));
         for Each of Connection_Maps.Element (C) loop
            Put_Line ("   " & To_String (Each.Caller)
                     & "." & To_String (Each.RI_Name)
                     & " -> " & To_String (Each.Callee) & "." &
                     To_String (Each.PI_Name));
         end loop;
      end loop;

      return IV_AST : constant Complete_Interface_View :=
          (Flat_Functions  => Funcs,
           End_To_End_Conn => Routes,
           Nested_Conn     => Routes_Map);
   end AADL_to_Ada_IV;

end Buildsupport_Utils;
