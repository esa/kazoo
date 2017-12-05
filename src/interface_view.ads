--  *************************** taste aadl parser ***********************  --
--  (c) 2017 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

--  Interface View parser

with Ocarina,
     Ocarina.Types,
     Ocarina.Backends.Properties,
     Ada.Containers.Indefinite_Ordered_Maps,
     Ada.Containers.Indefinite_Vectors,
     Ada.Strings.Unbounded,
     Option_Type,
     Parser_Utils;

use Ocarina,
    Ocarina.Types,
    Ocarina.Backends.Properties,
    Ada.Containers,
    Ada.Strings.Unbounded,
    Parser_Utils;

package Interface_View is

   use Option_UString;
   use Option_ULL;

   --  Exceptions specific to the Interface View
   No_RCM_Error      : exception;   -- Missing Periodic, Sporadic... property
   Interface_Error   : exception;   -- Any kind of interface parsing error
   Function_Error    : exception;   -- Any kind of function parsing error

   type Synchronism is (Sync, Async);

   type Supported_RCM_Operation_Kind is (Unprotected_Operation,
                                         Protected_Operation,
                                         Cyclic_Operation,
                                         Sporadic_Operation,
                                         Any_Operation);

   function Get_RCM_Operation_Kind (E : Node_Id)
     return Supported_RCM_Operation_Kind;

   function Get_RCM_Operation (E : Node_Id) return Node_Id;

   function Get_RCM_Period (D : Node_Id) return Unsigned_Long_Long;

   type Supported_ASN1_Encoding is (Default, Native, UPER, ACN);

   function Get_ASN1_Encoding (E : Node_Id) return Supported_ASN1_Encoding;

   type Supported_ASN1_Basic_Type is (ASN1_Sequence,
                                      ASN1_SequenceOf,
                                      ASN1_Enumerated,
                                      ASN1_Set,
                                      ASN1_SetOf,
                                      ASN1_Integer,
                                      ASN1_Boolean,
                                      ASN1_Real,
                                      ASN1_OctetString,
                                      ASN1_Choice,
                                      ASN1_String,
                                      ASN1_Unknown);

   function Get_ASN1_Basic_Type (E : Node_Id) return Supported_ASN1_Basic_Type;

   function Get_Ada_Package_Name (D : Node_Id) return Name_Id;

   function Get_Ellidiss_Tool_Version (D : Node_Id) return Name_Id;

   function Get_ASN1_Module_Name (D : Node_Id) return String;

   type Parameter_Direction is (param_in, param_out);

   type ASN1_Parameter is
      record
         Name            : Unbounded_String;
         Sort            : Unbounded_String;
         ASN1_Module     : Unbounded_String;
         ASN1_Basic_Type : Supported_ASN1_Basic_Type;
         ASN1_File_Name  : Unbounded_String;
         Encoding        : Supported_ASN1_Encoding;
         Direction       : Parameter_Direction;
      end record;

   package Parameters is new Indefinite_Vectors (Natural, ASN1_Parameter);

   --  Remote entities reference to the other ends of an interface, when it
   --  is connected. There can be several, but connections are optional.
   type Remote_Entity is
      record
         Function_Name  : Unbounded_String;
         Interface_Name : Unbounded_String;
      end record;

   package Remote_Entities is new Indefinite_Vectors (Natural, Remote_Entity);

   type Taste_Interface is
      record
         Name              : Unbounded_String;
         Parent_Function   : Unbounded_String;
         Remote_Interfaces : Remote_Entities.Vector;
         Params            : Parameters.Vector;
         RCM               : Supported_RCM_Operation_Kind;
         Period_Or_MIAT    : Unsigned_Long_Long;
         WCET_ms           : Optional_Long_Long := Nothing;
         Queue_Size        : Optional_Long_Long := Nothing;
         User_Properties   : Property_Maps.Map;
      end record;

   package Interfaces_Maps is new Indefinite_Ordered_Maps (String,
                                                           Taste_Interface);

   type Context_Parameter is
      record
         Name           : Unbounded_String;
         Sort           : Unbounded_String;
         Default_Value  : Unbounded_String;
         ASN1_Module    : Unbounded_String;
         ASN1_File_Name : Optional_Unbounded_String := Nothing;
      end record;

   package Ctxt_Params is new Indefinite_Vectors (Natural, Context_Parameter);

   type Taste_Terminal_Function is
      record
         Name            : Unbounded_String;
         Context         : Unbounded_String          := Null_Unbounded_String;
         Full_Prefix     : Optional_Unbounded_String := Nothing;
         Language        : Supported_Source_Language;
         Zip_File        : Optional_Unbounded_String := Nothing;
         Context_Params  : Ctxt_Params.Vector;
         User_Properties : Property_Maps.Map;
         Timers          : String_Vectors.Vector;
         Provided        : Interfaces_Maps.Map;
         Required        : Interfaces_Maps.Map;
      end record;

   package Function_Maps is new Indefinite_Ordered_Maps (String,
                                                      Taste_Terminal_Function);

   type Connection is
      record
         Caller  : Unbounded_String;
         Callee  : Unbounded_String;
         RI_Name : Unbounded_String;
         PI_Name : Unbounded_String;
      end record;

   package Option_Connection is new Option_Type (Connection);
   subtype Optional_Connection is Option_Connection.Option;

   package Channels is new Indefinite_Vectors (Natural, Connection);
   package Connection_Maps is new Indefinite_Ordered_Maps (String,
                                                          Channels.Vector,
                                                          "=" => Channels."=");

   type Complete_Interface_View is tagged
      record
         Flat_Functions  : Function_Maps.Map;
      end record;

   --  Function to build up the Ada AST by transforming the one from Ocarina
   function Parse_Interface_View (System : Node_Id)
                                  return Complete_Interface_View
   with Pre => System /= No_Node;

   --  Model transformation API: Rename a function
   procedure Rename_Function (IV       : in out Complete_Interface_View;
                              From, To : String);

   procedure Rename_Provided_Interface (IV    : in out Complete_Interface_View;
                                        Func  : String;
                                        Iface : String;
                                        To    : String);

   procedure Rename_Required_Interface (IV    : in out Complete_Interface_View;
                                        Func  : String;
                                        Iface : String;
                                        To    : String);

   procedure Debug_Dump (IV : Complete_Interface_View);

end Interface_View;
