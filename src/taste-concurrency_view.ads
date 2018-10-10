--  *************************** taste aadl parser ***********************  --
--  (c) 2018 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

--  Model of the Concurrency View

with Ada.Containers.Indefinite_Ordered_Maps,
     --  Ada.Containers.Indefinite_Vectors,
     Ada.Strings.Unbounded,
     --  Ada.Strings.Equal_Case_Insensitive,
     --  Ada.Strings.Less_Case_Insensitive,
     --  Text_IO,
     --  Option_Type,
     TASTE.Parser_Utils;

use Ada.Containers,
    Ada.Strings.Unbounded,
    --  Text_IO,
    TASTE.Parser_Utils;

package TASTE.Concurrency_View is

   --  use Option_UString;
   --  use Option_ULL;

   --  Exceptions specific to the Concurrency View
   Concurrency_View_Error : exception;

   type Port_Kind is (In_Port, Out_Port, In_Data, Out_Data);

   type Port (Kind : Port_Kind) is
      record
         Name            : Unbounded_String;
         case Kind is
            when In_Data | Out_Data =>
               Sort    : Unbounded_String;
            when others             =>
               null;
         end case;
      end record;

   package Ports_Pkg is new Indefinite_Ordered_Maps (String, Port);

   type Process is
      record
         Name           : Unbounded_String;
         Ports          : Ports_Pkg.Map;
      end record;

--         ASN1_File_Name : Optional_Unbounded_String := Nothing;
--  package Ctxt_Params is new Indefinite_Vectors (Natural, Context_Parameter);
--     Context         : Unbounded_String          := Null_Unbounded_String;
   --  Key for the function map is case insensitive
--  package Option_Connection is new Option_Type (Connection);
--  subtype Optional_Connection is Option_Connection.Option;

--    procedure Debug_Dump (IV : Complete_Interface_View; Output : File_Type);

end TASTE.Concurrency_View;
