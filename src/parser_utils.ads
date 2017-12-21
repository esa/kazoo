--  *************************** taste aadl parser ***********************  --
--  (c) 2017 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

--  Set of helper functions for the parser
with Ocarina,
     Ocarina.Types,
     Ocarina.Namet,
     Ada.Containers.Indefinite_Ordered_Maps,
     Ada.Containers.Indefinite_Vectors,
     Ocarina.ME_AADL.AADL_Tree.Nodes,
     Ocarina.ME_AADL.AADL_Instances.Nodes,
     Ada.Strings.Unbounded,
     Option_Type,
     GNAT.Strings,
     Interfaces.C_Streams;

use Ocarina,
    Ocarina.Types,
    Ocarina.Namet,
    Ocarina.ME_AADL.AADL_Tree.Nodes,
    Ocarina.ME_AADL.AADL_Instances.Nodes,
    Ada.Containers,
    Ada.Strings.Unbounded,
    Interfaces.C_Streams;

package Parser_Utils is

   Default_Interface_View  : aliased String := "InterfaceView.aadl";
   Default_Deployment_View : aliased String := "DeploymentView.aadl";
   Default_Data_View       : aliased String := "DataView.aadl";

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

   procedure Banner;

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
   package String_Vectors is new Indefinite_Vectors (Natural, String);
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
   use Option_UString;
   subtype Optional_Unbounded_String is Option_UString.Option;
   package Option_ULL is new Option_Type (Unsigned_Long_Long);
   use Option_ULL;
   subtype Optional_Long_Long is Option_ULL.Option;

   procedure Initialize_Ocarina;

   type Taste_Configuration is
      record
         Interface_View   : aliased GNAT.Strings.String_Access;
         Deployment_View  : aliased GNAT.Strings.String_Access;
         Data_View        : aliased GNAT.Strings.String_Access;
         Output_Dir       : aliased GNAT.Strings.String_Access;
         Skeletons        : aliased Boolean := False;
         Glue             : aliased Boolean := False;
         Use_POHIC        : aliased Boolean := False;
         Timer_Resolution : aliased Integer := 100;
         Debug_Flag       : aliased Boolean := False;
         Version          : aliased Boolean := False;
         Other_Files      : String_Vectors.Vector;
      end record;

   Current_Config : Taste_Configuration;

   procedure Parse_Command_Line (Result : out Taste_Configuration);

   procedure Dump_Configuration (Config : Taste_Configuration);

end Parser_Utils;
