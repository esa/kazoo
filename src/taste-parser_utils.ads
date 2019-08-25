--  *************************** taste aadl parser ***********************  --
--  (c) 2008-2018 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

--  Set of helper functions for the parser
with Ada.Containers.Indefinite_Ordered_Maps,
     Ada.Containers.Indefinite_Ordered_Sets,
     Ada.Containers.Indefinite_Vectors,
     Ada.Containers.Indefinite_Holders,
     Ada.Strings.Unbounded,
     Ada.Strings.Equal_Case_Insensitive,
     Ada.Strings.Less_Case_Insensitive,
     Text_IO,
     Interfaces.C_Streams,
     Templates_Parser,
     Ocarina,
     Ocarina.Types,
     Ocarina.Namet,
     Ocarina.ME_AADL.AADL_Tree.Nodes,
     Ocarina.ME_AADL.AADL_Instances.Nodes,
     Option_Type;

use Ocarina,
    Ocarina.Types,
    Ocarina.Namet,
    Ocarina.ME_AADL.AADL_Tree.Nodes,
    Ocarina.ME_AADL.AADL_Instances.Nodes,
    Ada.Containers,
    Ada.Strings.Unbounded,
    Text_IO,
    Interfaces.C_Streams,
    Templates_Parser;

package TASTE.Parser_Utils is

   AADL_Language           : Name_Id;
   Default_Interface_View  : constant String := "InterfaceView.aadl";
   Default_Deployment_View : constant String := "DeploymentView.aadl";
   Default_Data_View       : constant String := "DataView.aadl";

   --  Create a case insensitive string type, that can be used as keys for maps
   subtype Case_Insensitive_String is String;
   function "="(Left, Right : Case_Insensitive_String) return Boolean
      renames Ada.Strings.Equal_Case_Insensitive;
   function "<"(Left, Right : Case_Insensitive_String) return Boolean
      renames Ada.Strings.Less_Case_Insensitive;

   package ATN renames Ocarina.ME_AADL.AADL_Tree.Nodes;
   package AIN renames Ocarina.ME_AADL.AADL_Instances.Nodes;
   function US (Source : String) return Unbounded_String renames
       To_Unbounded_String;

   Yellow      : constant String := ASCII.ESC & "[33m";
   White       : constant String := ASCII.ESC & "[37m";
   Red         : constant String := ASCII.ESC & "[31m";
   Bold        : constant String := ASCII.ESC & "[1m";

   function Is_Tty return Boolean is (Isatty (Fileno (Stdout)) /= 0);
   function Red_Bold return String is (if Is_Tty then Red & Bold else "");
   function Yellow_Bold return String is
     (if Is_Tty then Yellow & Bold else "");
   function No_Color return String is
     (if Is_Tty then ASCII.ESC & "[0m" else "");
   function Underline return String is
     (if Is_Tty then ASCII.ESC & "[4m" else "");
   function White_Bold return String is (if Is_Tty then White & Bold else "");

   function Strip_String (Input_String : String) return String;

   procedure Put_Info  (Info  : String);
   procedure Put_Error (Error : String);
   procedure Put_Debug (Debug : String);

   procedure Banner;

   package String_Holders is new Indefinite_Holders (String);

   --  Custom filters for Templates_Parser

   --  Return a list without duplicates
   --  @_UNIQ(separator):Tag_@
   function Filter_Uniq
     (Value, Parameters : String;
      unused_Context    :  Filter_Context) return String;

   --  Generate documentation for a translate set
   procedure Document_Template (Source_Folder, Template_Name : String;
                                T : Translate_Set);

   AADL_Parser_Error : exception;

   function Get_APLC_Binding (E : Node_Id) return List_Id;

   function Get_Interface_Name (D : Node_Id) return Name_Id;

   --  Record to store properties
   type User_Property is
      record
         Name  : Unbounded_String;
         Value : Unbounded_String;
      end record;
   package Property_Maps is new Indefinite_Ordered_Maps (String,
                                                         User_Property);
   use Property_Maps;
   package String_Vectors is new Indefinite_Vectors (Natural, String,
                                           Ada.Strings.Equal_Case_Insensitive);
   package String_Sets is new Indefinite_Ordered_Sets
      (Element_Type => String,
       "<"          => Ada.Strings.Less_Case_Insensitive,
       "="          => Ada.Strings.Equal_Case_Insensitive);

   --  Helper function translating directly a string set to a templates Tag
   function To_Template_Tag (SS : String_Sets.Set) return Tag;

   function Get_Properties_Map (D : Node_Id) return Property_Maps.Map;

   --  Shortcut to read an identifier from the parser, in lowercase
   function ATN_Lower (N : Node_Id) return String is
       (Get_Name_String (ATN.Name (ATN.Identifier (N))));

   --  Shortcut to read an identifier from the parser, with original case
   function ATN_Case (N : Node_Id) return String is
       (Get_Name_String (ATN.Display_Name (ATN.Identifier (N))));

   --  Shortcut to read an identifier from the parser, in lowercase
   function AIN_Lower (N : Node_Id) return String is
       (Get_Name_String (AIN.Name (AIN.Identifier (N))));

   --  Shortcut to read an identifier from the parser, with original case
   function AIN_Case (N : Node_Id) return String is
       (Get_Name_String (AIN.Display_Name (AIN.Identifier (N))));

   package Option_UString is new Option_Type (Unbounded_String);
   --  use Option_UString;
   --  subtype Optional_Unbounded_String is Option_UString.Option;
   package Option_ULL is new Option_Type (Unsigned_Long_Long);
   --  use Option_ULL;
   --  subtype Optional_Long_Long is Option_ULL.Option;

   procedure Initialize_Ocarina;

   subtype String_Holder is String_Holders.Holder;
   type Taste_Configuration is tagged
      record
         Binary_Path      : String_Holder;
         Interface_View   : String_Holder;
         Deployment_View  : String_Holder;
         Data_View        : String_Holder;
         Output_Dir       : String_Holder;
         Check_Data_View  : aliased Boolean := False;
         Skeletons        : aliased Boolean := True;
         Glue             : aliased Boolean := False;
         Use_POHIC        : aliased Boolean := False;
         Timer_Resolution : aliased Integer := 100;
         Debug_Flag       : aliased Boolean := False;
         No_Stdlib        : aliased Boolean := False;
         Other_Files      : String_Vectors.Vector;
      end record;

   function To_Template (Config : Taste_Configuration) return Translate_Set;

   procedure Debug_Dump         (Config :     Taste_Configuration;
                                 Output :     File_Type);
   procedure Parse_Command_Line (Result : out Taste_Configuration);

   --  Define a vector for template_parser translate sets
   package Translate_Sets is new Indefinite_Vectors (Natural, Translate_Set);

   --  There is no "&" operator for Translate sets...
   function Join_Sets (S1, S2 : Translate_Set) return Translate_Set;

private
   Debug_Mode : Boolean := False;
end TASTE.Parser_Utils;
