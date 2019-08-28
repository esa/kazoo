--  *************************** taste aadl parser ***********************  --
--  (c) 2017-2019 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

--  Interface View parser

with Ada.Exceptions,
     Ocarina.Instances.Queries,
     Ocarina.Analyzer,
     Ocarina.Options,
     Ocarina.Instances,
     Ocarina.Backends.Properties,
     Ocarina.ME_AADL.AADL_Tree.Nodes,
     Ocarina.ME_AADL.AADL_Instances.Nodes,
     Ocarina.Namet,
     Ocarina.ME_AADL.AADL_Tree.Nutils,
     Ocarina.ME_AADL.AADL_Instances.Nutils,
     Ocarina.ME_AADL.AADL_Instances.Entities,
     Ocarina.Backends.Utils;

package body TASTE.Interface_View is

   use Ada.Exceptions,
       Ocarina.Instances.Queries,
       Ocarina.Namet,
       --  Ocarina.Analyzer,
       Ocarina.Options,
       Ocarina.Instances,
       Ocarina.Backends.Properties,
       Ocarina.ME_AADL.AADL_Instances.Nodes,
       Ocarina.ME_AADL.AADL_Instances.Nutils,
       Ocarina.ME_AADL.AADL_Instances.Entities,
       Ocarina.ME_AADL,
       Ocarina.Backends.Utils;

   package ATN  renames Ocarina.ME_AADL.AADL_Tree.Nodes;
   package ATNU renames Ocarina.ME_AADL.AADL_Tree.Nutils;

   ------------------------------
   -- Get_Language (as string) --
   ------------------------------

   function Get_Language (E : Node_Id) return String is
      Source_Property : constant Name_Id :=
         Get_String_Name ("source_language");
   begin
      if Is_Defined_List_Property (E, Source_Property) then
         declare
            Source_Language_List : constant List_Id :=
               Get_List_Property (E, Source_Property);
         begin
            if ATNU.Length (Source_Language_List) > 1 then
               raise Interface_Error with "Cannot use more than one language";
            end if;

            return Get_Name_String
               (ATN.Name
                  (ATN.Identifier (ATN.First_Node (Source_Language_List))));
         end;
      else
         return "None";
      end if;
   end Get_Language;

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

         elsif RCM_Operation_Kind_N = Protected_Name then
            return Protected_Operation;

         elsif RCM_Operation_Kind_N = Cyclic_Name then
            return Cyclic_Operation;

         elsif RCM_Operation_Kind_N = Sporadic_Name then
            return Sporadic_Operation;

         elsif RCM_Operation_Kind_N = Any_Name then
            return Any_Operation;
         end if;
      end if;
      raise No_RCM_Error;
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

   ---------------------------
   -- Get ASN.1 Module name --
   ---------------------------

   function Get_ASN1_Module_Name (D : Node_Id) return String is
      id : Name_Id;
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
      raise Interface_Error with "ASN1 Encoding not set";
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
      raise Interface_Error with "ASN.1 Basic type undefined!";
      return ASN1_Unknown;
   end Get_ASN1_Basic_Type;

   ----------------------------------------------------------------
   -- Get Optional Worse Case Execution Time (Upper bound in ms) --
   ----------------------------------------------------------------

   function Get_Upper_WCET (Func : Node_Id) return Option_ULL.Option is
      (if Is_Subprogram_Access (Func) and then Sources (Func) /= No_List
         and then AIN.First_Node (Sources (Func)) /= No_Node
         and then Get_Execution_Time (Corresponding_Instance (AIN.Item
                                           (AIN.First_Node (Sources (Func)))))
                           /= Empty_Time_Array
      then Just (To_Milliseconds (Get_Execution_Time (Corresponding_Instance
                             (AIN.Item (AIN.First_Node (Sources (Func)))))(1)))
         else Option_ULL.Nothing);

   ---------------------------
   -- AST Builder Functions --
   ---------------------------

   function Parse_Interface_View (Interface_Root : Node_Id)
                                  return Complete_Interface_View
   is
      --  use type Functions.Vector;
      use type Channels.Vector;
      use type Ctxt_Params.Vector;
      use type Parameters.Vector;
      --  use type Connection_Maps.Map;
      System                 : Node_Id;
      Success                : Boolean;
      Functions              : Function_Maps.Map;
      Routes_Map             : Connection_Maps.Map;
      End_To_End_Connections : Channels.Vector;
      Current_Function       : Node_Id;

      --  Parse a connection
      function Parse_Connection (Conn : Node_Id) return Optional_Connection is
         use Option_Connection;
         Caller  : constant Node_Id := AIN.Item (AIN.First_Node
                                         (AIN.Path (AIN.Destination (Conn))));
         Callee  : constant Node_Id := AIN.Item (AIN.First_Node
                                         (AIN.Path (AIN.Source (Conn))));
         PI_Name : Name_Id;  --  None in case of cyclic interface
         RI_Name : constant Name_Id := Get_Interface_Name
                              (Get_Referenced_Entity (AIN.Destination (Conn)));
      begin
         --  If RI_Name has no value it means the interface view misses the
         --  AADL property "TASTE::InterfaceName". Not supported.
         if RI_Name = No_Name then
            raise Interface_Error with "Interface view contains errors "
              & "(Missing TASTE::InterfaceName properties)"
              & ASCII.CR & ASCII.LF
              & "        Try updating it with taste-edit-project";
         end if;

         --  Filter out connections if the PI is cyclic (not a connection!)
         if Get_RCM_Operation_Kind
           (Get_Referenced_Entity (AIN.Destination (Conn))) = Cyclic_Operation
         then
            return Option_Connection.Nothing;
         end if;

         PI_Name := Get_Interface_Name
                                  (Get_Referenced_Entity (AIN.Source (Conn)));

         return Just (Connection'(Caller =>
           (if Kind (Caller) = K_Subcomponent_Access_Instance then US ("_env")
            else US (AIN_Case (Caller))),
                            Callee =>
           (if Kind (Callee) = K_Subcomponent_Access_Instance then US ("_env")
            else US (AIN_Case (Callee))),
                            PI_Name => US (Get_Name_String (PI_Name)),
                            RI_Name => US (Get_Name_String (RI_Name))));
      end Parse_Connection;

      --  Create a vector of connections for a given system
      --  This vector will then be filtered to connect end-to-end functions
      --  once the system is flattened
      function Parse_System_Connections (System : Node_Id)
         return Channels.Vector
      is
         use Option_Connection;
         Conn     : Node_Id;
         Result   : Channels.Vector;
         Opt_Conn : Optional_Connection;
      begin
         if Present (AIN.Connections (System)) then
            Conn := AIN.First_Node (AIN.Connections (System));
            while Present (Conn) loop
               Opt_Conn := Parse_Connection (Conn);
               if Opt_Conn.Has_Value then
                  Result := Result & Opt_Conn.Unsafe_Just;
               end if;
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
                               else Option_UString.Nothing));
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
                                   (CI, "taste::associated_queue_size"))
                               else Option_ULL.Nothing);
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
      exception
         when No_RCM_Error =>
            raise Interface_Error with "Interface " & To_String (Result.Name)
                                       & " has no kind "
                                       & "(periodic, sporadic ...)";
      end Parse_Interface;

      --  Helper function - return the context name above the current one
      --  Needed to resolve the connections to "_env".
      function Parent_Context (Context : String) return String is
      begin
         for Each in Routes_Map.Iterate loop
            if Context /= Connection_Maps.Key (Each) then
               for Conn of Connection_Maps.Element (Each) loop
                  if Conn.Caller = Context or Conn.Callee = Context then
                     return Connection_Maps.Key (Each);
                  end if;
               end loop;
            end if;
         end loop;
         return "ERROR";
      end Parent_Context;

      --  Recursive function making jumps to find the provided interface
      --  connected to a required interface. It returns a Remote Entity,
      --  which contains the name of the remote PI and the name of the function
      function Rec_Jump (From : String; RI : String;
                         Going_Out : Boolean := False) return Remote_Entity is
         Context     : constant String :=
           (if Functions.Contains (Key => From)
            then To_String (Functions.Element (Key => From).Context)
            else (if not Going_Out then From else Parent_Context (From)));
         Source      : constant String :=
           (if Context /= From then From else "_env");
         Result      : Remote_Entity := (US ("Not found!"), US ("Not found!"));
         Connections : Channels.Vector;
         Set_Going_Out : Boolean := False;
      begin
         --  Note: There is a limitation in the interface view when there are
         --  nested functions. At the border of a nested function, there can
         --  be only ONE function of a given name. This means that it is
         --  impossible to have two PIs with the same name, even in different
         --  functions, if they are located in the same nested context.
         --  * This is NOT RIGHT and should be fixed by Ellidiss *

         --  Retrieve the list of connections of the source function context
         Connections := Routes_Map.Element (Key => Context);
         for Each of Connections loop
            if Each.Caller = Source and Each.RI_Name = US (RI) then
               --  Found the connection in the current context
               --  Now recurse if the callee is a nested block,
               --  and return otherwise (if destination is a function)
               if Each.Callee = "_env" then
                  Set_Going_Out := True;
               end if;

               Result :=
                 (if Functions.Contains (Key => To_String (Each.Callee))
                  then (Function_Name  => Each.Callee,
                        Interface_Name => Each.PI_Name)
                  else Rec_Jump (From      => (if not Set_Going_Out
                                               then To_String (Each.Callee)
                                               else Context),
                                 Going_Out => Set_Going_Out,
                                 RI        => To_String (Each.PI_Name)));
            end if;

            exit when Each.Caller = Source and Each.RI_Name = US (RI);
         end loop;
         return Result;
      end Rec_Jump;

      --  Parse the following content of a single function :
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
         Zip_Id      : Name_Id;
         --  To get the context parameters
         Subco       : Node_Id;
         --  To get the provided and required interfaces
         PI_Or_RI    : Node_Id;
         Iface       : Taste_Interface;
      begin
         Result.Name          := US (Name);
         Result.Full_Prefix   := (if Prefix'Length > 0 then Just (US (Prefix))
                                 else Option_UString.Nothing);
         --  Result.Language      := Get_Source_Language (Inst);
         Result.Language      := US (Get_Language (Inst));
         if Source_Text'Length /= 0 then
            Zip_Id          := Source_Text (1);
            Result.Zip_File := Just (US (Get_Name_String (Zip_Id)));
         end if;
         --  Parse context parameters (including timers)
         if Present (AIN.Subcomponents (Inst)) then
            Subco := AIN.First_Node (AIN.Subcomponents (Inst));
            while Present (Subco) loop
               case Get_Category_Of_Component (Subco) is
                  when CC_Data =>
                     declare
                        CP : constant Context_Parameter := Parse_CP (Subco);
                        use String_Vectors;
                     begin
                        if CP.Sort = "Timer" then
                           Result.Timers := Result.Timers
                                            & To_String (CP.Name);
                        elsif CP.Sort = "Taste-directive" then
                           Result.Directives := Result.Directives & CP;
                        elsif CP.Sort = "Simulink-Tunable-Parameter" then
                           Result.Simulink := Result.Simulink & CP;
                        else
                           --  Standard Context Parameter (for C/C++/Ada)
                           Result.Context_Params := Result.Context_Params & CP;
                        end if;
                     end;
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
               Iface                 := Parse_Interface (PI_Or_RI);
               Iface.Parent_Function := Result.Name;
               Iface.Language        := Result.Language;
               if AIN.Is_Provided (PI_Or_RI) then
                  Result.Provided.Insert (Key      => To_String (Iface.Name),
                                          New_Item => Iface);
               else
                  Result.Required.Insert (Key      => To_String (Iface.Name),
                                          New_Item => Iface);
               end if;
               PI_Or_RI := AIN.Next_Node (PI_Or_RI);
            end loop;
         end if;
         Result.User_Properties := Get_Properties_Map (Inst);

         --  Check User properties for first-class attributes
         --  Currently: component type and instance
         for Each of Result.User_Properties loop
            if Each.Name = "TASTE_IV_Properties::is_Component_Type" and then
               Each.Value = "true"
            then
               Result.Is_Type := True;
            end if;
            if Each.Name = "TASTE_IV_Properties::is_instance_of" then
               Result.Instance_Of := Just (Each.Value);
            end if;
         end loop;

         return Result;
      exception
         when Error : Interface_Error =>
            raise Function_Error with "Function " & To_String (Result.Name)
                                      & " : " & Exception_Message (Error);
      end Parse_Function;

      --  Recursive parsing of a system made of nested functions (TASTE v2)
      function Rec_Function (Prefix : String  := "";
                             Context : String := "_Root";
                             Func   : Node_Id) return Boolean
        with Pre => Prefix'Length <= Integer'Last - 1
      is

         Inner        : Node_Id;
         Is_Terminal  : Boolean := True;
         CI           : constant Node_Id := Corresponding_Instance (Func);
         Name         : constant String := AIN_Case (Func);
         Next_Prefix  : constant String := Prefix &
                           (if Prefix'Length > 0 then "." else "") & Name;
         Terminal_Fn  : Taste_Terminal_Function;
      begin
         case Get_Category_Of_Component (CI) is
            when CC_System =>
               if Present (AIN.Subcomponents (CI)) then
                  Inner := AIN.First_Node (AIN.Subcomponents (CI));
                  while Present (Inner) loop
                     Is_Terminal := Rec_Function (Prefix  => Next_Prefix,
                                                  Context => Name,
                                                  Func    => Inner);
                     Inner := AIN.Next_Node (Inner);
                  end loop;

                  --  Inner components may not be functions but properties
                  if not Is_Terminal
                  then
                     Routes_Map.Insert (Key      => Name,
                                        New_Item =>
                                                Parse_System_Connections (CI));
                  end if;
               end if;

               if No (AIN.Subcomponents (CI)) or Is_Terminal
               then
                  Terminal_Fn := Parse_Function (Prefix => Prefix,
                                                 Name   => Name,
                                                 Inst   => CI);
                  Terminal_Fn.Context := US (Context);
                  Functions.Insert (Key       => Name,
                                    New_Item  => Terminal_Fn);
                  Is_Terminal := False;
               end if;
            when others =>
               null;
         end case;

         return Is_Terminal;
      end Rec_Function;
   begin
      Put_Info ("Parsing interface view");
      if No (Interface_Root) then
         raise Interface_Error with "Interface View parsing error";
      end if;

      Success := Ocarina.Analyzer.Analyze (AADL_Language, Interface_Root);

      if not Success then
         raise Interface_Error with "Could not analyse Interface View";
      end if;

      Ocarina.Options.Root_System_Name :=
        Get_String_Name ("interfaceview.others");

      System := Root_System (Instantiate_Model (Root => Interface_Root));

      if No (System) then
         raise Interface_Error with "Could not instantiate Interface View";
      end if;

      Current_Function := AIN.First_Node (AIN.Subcomponents (System));
      --  Parse functions recursively
      while Present (Current_Function) loop
         declare
            dummy : constant Boolean := Rec_Function
              (Func => Current_Function);
         begin
            Current_Function := AIN.Next_Node (Current_Function);
         end;
      end loop;

      --  Routes_Map contains all connections including the nested ones
      --  It is used in Rec_Jump to resolve all end-to-end connections
      Routes_Map.Insert (Key      => "_Root",
                         New_Item => Parse_System_Connections (System));

      --  Resolve the PI-RI connections within the functions
      for Each of Functions loop
         for RI of Each.Required loop
            declare
               --  From a RI, follow the connection until the remote PI
               Remote : constant Remote_Entity := Rec_Jump
                                                     (To_String (Each.Name),
                                                      To_String (RI.Name));
            begin
               if Remote.Function_Name /= "Not found!" then
                  RI.Remote_Interfaces.Append (Remote);
                  --  Update RCM of the RI to match the one of the remote PI
                  --  (by default it is set to Any)
                  RI.RCM :=
                    Functions (To_String (Remote.Function_Name)).Provided
                      (To_String (Remote.Interface_Name)).RCM;

                  --  Update list of end to end connections with RI->PI
                  End_To_End_Connections := End_To_End_Connections
                    & (Caller  => Each.Name,
                       Callee  => Remote.Function_Name,
                       RI_Name => RI.Name,
                       PI_Name => Remote.Interface_Name);
               end if;
            end;
         end loop;
      end loop;
      --  Do the same for the PIs - they could not be updated at the same time
      --  because when we iterate on the functions, we can modify only the
      --  current function - we cannot touch the one with the remote PI.
      for Each of Functions loop
         for PI of Each.Provided loop

            --  Add periodic PIs to the list of connections
            if PI.RCM = Cyclic_Operation and not Each.Is_Type then
               End_To_End_Connections := End_To_End_Connections
                 & (Caller  => US ("ENV"),
                    Callee  => Each.Name,
                    RI_Name => PI.Name,
                    PI_Name => PI.Name);
            end if;

            for Fn of Functions loop
               for RI of Fn.Required loop
                  for Remote of RI.Remote_Interfaces loop
                     if Remote.Function_Name = Each.Name and then
                       Remote.Interface_Name = PI.Name
                     then
                        PI.Remote_Interfaces.Append
                                (Remote_Entity'(Function_Name  => Fn.Name,
                                                Interface_Name => RI.Name));
                     end if;
                  end loop;
               end loop;
            end loop;
         end loop;
      end loop;

      return IV_AST : constant Complete_Interface_View :=
        (Flat_Functions => Functions,
         Connections    => End_To_End_Connections);
   end Parse_Interface_View;

   procedure Rename_Function (IV       : in out Complete_Interface_View;
                              From, To : String)
   is
      FV        : Taste_Terminal_Function :=
                                       IV.Flat_Functions.Element (Key => From);
      Remote_FV : Taste_Terminal_Function;
      Remote_If : Taste_Interface;
   begin
      FV.Name := US (To);
      for Each of FV.Provided loop
         Each.Parent_Function := FV.Name;
         --  Update the "Remote Function Name" of all connected interfaces
         for Remote of Each.Remote_Interfaces loop
            Remote_FV := IV.Flat_Functions.Element
                                     (Key => To_String (Remote.Function_Name));
            Remote_If := Remote_FV.Required.Element
                                    (Key => To_String (Remote.Interface_Name));
            for Entity of Remote_If.Remote_Interfaces loop
               if Entity.Function_Name = US (From) then
                  Entity.Function_Name := FV.Name;
               end if;
            end loop;
         end loop;
      end loop;
      for Each of FV.Required loop
         Each.Parent_Function := FV.Name;
         --  Update the "Remote Function Name" of all connected interfaces
         for Remote of Each.Remote_Interfaces loop
            Remote_FV := IV.Flat_Functions.Element
                                     (Key => To_String (Remote.Function_Name));
            Remote_If := Remote_FV.Provided.Element
                                    (Key => To_String (Remote.Interface_Name));
            for Entity of Remote_If.Remote_Interfaces loop
               if Entity.Function_Name = US (From) then
                  Entity.Function_Name := FV.Name;
               end if;
            end loop;
         end loop;
      end loop;
      IV.Flat_Functions.Delete (Key => From);
      IV.Flat_Functions.Insert (Key      => To,
                                New_Item => FV);
   end Rename_Function;

   procedure Rename_Provided_Interface (IV    : in out Complete_Interface_View;
                                        Func  : String;
                                        Iface : String;
                                        To    : String) is
      FV        : Taste_Terminal_Function :=
                    IV.Flat_Functions.Element (Key => Func);
      FV_If     : Taste_Interface :=
                    FV.Provided.Element (Key => Iface);
   begin
      FV_If.Name := US (To);
      FV.Provided.Delete (Key       => Iface);
      FV.Provided.Insert  (Key      => To,
                           New_Item => FV_If);
      --  Now fix all references to this interface
      for Each of IV.Flat_Functions loop
         for RI of Each.Required loop
            for Remote of RI.Remote_Interfaces loop
               if Remote.Function_Name = FV.Name and then
                 Remote.Interface_Name = US (Iface)
               then
                  Remote.Interface_Name := FV_If.Name;
               end if;
            end loop;
         end loop;
      end loop;
   end Rename_Provided_Interface;

   procedure Rename_Required_Interface (IV    : in out Complete_Interface_View;
                                        Func  : String;
                                        Iface : String;
                                        To    : String) is
      FV        : Taste_Terminal_Function :=
                    IV.Flat_Functions.Element (Key => Func);
      FV_If     : Taste_Interface :=
                    FV.Provided.Element (Key => Iface);
   begin
      FV_If.Name := US (To);
      FV.Required.Delete (Key       => Iface);
      FV.Required.Insert  (Key      => To,
                           New_Item => FV_If);
      --  Now fix all references to this interface
      for Each of IV.Flat_Functions loop
         for PI of Each.Provided loop
            for Remote of PI.Remote_Interfaces loop
               if Remote.Function_Name = FV.Name and then
                 Remote.Interface_Name = US (Iface)
               then
                  Remote.Interface_Name := FV_If.Name;
               end if;
            end loop;
         end loop;
      end loop;
   end Rename_Required_Interface;

   procedure Debug_Dump (IV : Complete_Interface_View; Output : File_Type) is
      procedure Dump_Interface (I         : Taste_Interface;
                                Last_Leaf : Boolean := False;
                                Last_IF    : Boolean := False)
      is
         Ind : constant String := (if not Last_Leaf then "│  " else "   ");
         Bar : constant String := (if not Last_IF then "│  " else "   ");
         Pre : constant String := Ind & Bar;
      begin
         Put_Line (Output, Ind & (if Last_IF then "└─" else "├─")
                               & " Name : "
                   & To_String (I.Name) & " - in FV: "
                   & To_String (I.Parent_Function));
         Put_Line (Output, Pre & "├─ RCM Kind    : " & I.RCM'Img);
         Put_Line (Output, Pre & "├─ Period/MIAT : "
                               & I.Period_Or_MIAT'Img);
         Put_Line (Output, Pre & "├─ WCET (ms)   : "
                   & I.WCET_ms.Value_Or (0)'Img);
         Put_Line (Output, Pre & "├─ Queue Size  : "
                   & I.Queue_Size.Value_Or (1)'Img);
         Put_Line (Output, Pre & "├─ Parameters  :");
         for Each of I.Params loop
            Put_Line (Output, Pre & "│  ├─ Name            : "
                      & To_String (Each.Name));
            Put_Line (Output, Pre & "│  │  ├─ Type         : "
                      & To_String (Each.Sort));
            Put_Line (Output, Pre & "│  │  ├─ ASN.1 Module : "
                      & To_String (Each.ASN1_Module));
            Put_Line (Output, Pre & "│  │  ├─ ASN.1 File   : "
                      & To_String (Each.ASN1_File_Name));
            Put_Line (Output, Pre & "│  │  ├─ Basic type   : "
                      & Each.ASN1_Basic_Type'Img);
            Put_Line (Output, Pre & "│  │  ├─ Encoding     : "
                      & Each.Encoding'Img);
            Put_Line (Output, Pre & "│  │  └─ Direction    : "
                      & Each.Direction'Img);
         end loop;
         Put_Line (Output, Pre & "└─ Connections :");
         for Each of I.Remote_Interfaces loop
            Put_Line (Output, Pre & "   "
                      & (if I.Remote_Interfaces.Last_Element = Each
                         then "└─" else "├─")
                      & " Function "
                      & To_String (Each.Function_Name)
                      & ", interface " & To_String (Each.Interface_Name));
         end loop;
      end Dump_Interface;
   begin
      for Each of IV.Flat_Functions loop
         Put_Line (Output, "Function " & To_String (Each.Name)
                   & " in context " & To_String (Each.Context));

         Put_Line (Output, "├─ Full Prefix : "
                   & To_String (Value_Or (Each.Full_Prefix, US ("(none)"))));
         Put_Line (Output, "├─ Language    : "
                   & To_String (Each.Language));
         Put_Line (Output, "├─ Zip file    : "
                   & To_String (Value_Or (Each.Zip_File, US ("(none)"))));
         Put_Line (Output, "├─ Is type     : " & Each.Is_Type'Img);
         Put_Line (Output, "├─ Instance of : "
                   & To_String (Value_Or (Each.Instance_Of, US ("(n/a)"))));
         Put_Line (Output, "├─ Context Parameters :");
         for CP of Each.Context_Params loop
            Put_Line (Output, "│  "
                      & (if Each.Context_Params.Last_Element /= CP
                         then "├─ " else "└─ ")
                      & To_String (CP.Name) & " : "
                      & To_String (CP.Sort) & "- default : "
                      & To_String (CP.Default_Value) & " - asn1 module : "
                      & To_String (CP.ASN1_Module) & " - file : "
                      & To_String (Value_Or (CP.ASN1_File_Name,
                                             US ("(none)"))));
         end loop;
         Put_Line (Output, "├─ Directives:");
         for CP of Each.Directives loop
            Put_Line (Output, "│  "
                      & (if Each.Directives.Last_Element /= CP
                         then "├─ " else "└─ ")
                      & To_String (CP.Name) & " = "
                      & To_String (CP.Default_Value));
         end loop;
         Put_Line (Output, "├─ Simulink Tuneable Parameters:");
         for CP of Each.Simulink loop
            Put_Line (Output, "│  "
                      & (if Each.Simulink.Last_Element /= CP
                         then "├─ " else "└─ ")
                      & To_String (CP.Name) & " = "
                      & To_String (CP.Default_Value));
         end loop;

         Put_Line (Output, "├─ User properties:");
         for Ppty of Each.User_Properties loop
            Put_Line (Output, "│  "
                      & (if Ppty /= Each.User_Properties.Last_Element
                         then "├─ " else "└─ ")
                      & To_String (Ppty.Name) & " = "
                      & To_String (Ppty.Value));
         end loop;
         Put_Line (Output, "├─ Timers:");
         for Timer of Each.Timers loop
            Put_Line (Output, "│  "
               & (if Each.Timers.Last_Element /= Timer
                  then "├─ " else "└─ ")
               & Timer);
         end loop;
         Put_Line (Output, "├─ Provided interfaces:");
         for PI of Each.Provided loop
            Dump_Interface (I         => PI,
                            Last_Leaf => False,
                            Last_IF   => Each.Provided.Last_Element = PI);
         end loop;
         Put_Line (Output, "└─ Required interfaces:");
         for RI of Each.Required loop
            Dump_Interface (I         => RI,
                            Last_Leaf => True,
                            Last_IF   => Each.Required.Last_Element = RI);
         end loop;
         New_Line (Output);
      end loop;
   end Debug_Dump;

   --  Create a Templates_Parser translate set for an interface (PI or RI)
   function To_Template (TI : Taste_Interface) return Translate_Set is
      Param_Names,
      Param_Types,
      Param_ASN1_Modules,
      Param_Directions,
      Param_Encodings,
      Property_Names,
      Property_Values,
      Remote_Function_Names,
      Remote_Interface_Names : Vector_Tag;
   begin
      for Each of TI.Params loop
         Param_Names        := Param_Names & Each.Name;
         Param_Types        := Param_Types & Each.Sort;
         Param_ASN1_Modules := Param_ASN1_Modules & Each.ASN1_Module;
         Param_Directions   := Param_Directions & Each.Direction'Img;
         Param_Encodings    := Param_Encodings & Each.Encoding'Img;
      end loop;
      --  Add all function user-defined properties
      for Each of TI.User_Properties loop
         Property_Names  := Property_Names  & Each.Name;
         Property_Values := Property_Values & Each.Value;
      end loop;
      --  Add list of callers or callees
      for Each of TI.Remote_Interfaces loop
         Remote_Function_Names  := Remote_Function_Names & Each.Function_Name;
         Remote_Interface_Names := Remote_Interface_Names
           & Each.Interface_Name;
      end loop;

      return +Assoc ("Name",               TI.Name)
        & Assoc ("Kind",                   TI.RCM'Img)
        & Assoc ("Parent_Function",        TI.Parent_Function)
        & Assoc ("Language",               TI.Language)
        & Assoc ("Period",                 TI.Period_Or_MIAT'Img)
        & Assoc ("WCET",                   TI.WCET_ms.Value_Or (0)'Img)
        & Assoc ("Queue_Size",             TI.Queue_Size.Value_Or (1)'Img)
        & Assoc ("Param_Names",            Param_Names)
        & Assoc ("Param_Types",            Param_Types)
        & Assoc ("Param_ASN1_Modules",     Param_ASN1_Modules)
        & Assoc ("Param_Encodings",        Param_Encodings)
        & Assoc ("Param_Directions",       Param_Directions)
        & Assoc ("IF_Property_Names",      Property_Names)
        & Assoc ("IF_Property_Values",     Property_Values)
        & Assoc ("Remote_Function_Names",  Remote_Function_Names)
        & Assoc ("Remote_Interface_Names", Remote_Interface_Names);
   end To_Template;

end TASTE.Interface_View;
