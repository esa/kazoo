--  *************************** taste aadl parser ***********************  --
--  (c) 2018 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

--  Model of the Concurrency View

with Ada.Containers.Indefinite_Ordered_Maps,
     Ada.Containers.Indefinite_Vectors,
     Ada.Strings.Unbounded,
     Text_IO,
     Templates_Parser,
     TASTE.Parser_Utils,
     TASTE.Interface_View,
     TASTE.Deployment_View;

use Ada.Containers,
    Ada.Strings.Unbounded,
    Text_IO,
    Templates_Parser,
    TASTE.Parser_Utils,
    TASTE.Interface_View,
    TASTE.Deployment_View;

package TASTE.Concurrency_View is

   Concurrency_View_Error : exception;

   type Protected_Block_PI is
      record
         Name         : Unbounded_String;
         PI           : Taste_Interface;
         Local_Caller : Boolean := True;
      end record;

   package Protected_Block_PIs is new Indefinite_Ordered_Maps
     (String, Protected_Block_PI);

   type Protected_Block is tagged
      record
         Name            : Unbounded_String;
         Provided        : Protected_Block_PIs.Map;
         Required        : Interfaces_Maps.Map;
         Calling_Threads : String_Sets.Set;
         Node            : Option_Node.Option;
      end record;

   --  Data model for the template backends (templates_parser)
   type Block_As_Template is
      record
         Header   : Translate_Set;
         Provided : Translate_Sets.Vector;
         Required : Translate_Sets.Vector;
      end record;
   function To_Template (B : Protected_Block) return Block_As_Template;

   package Protected_Blocks is new Indefinite_Ordered_Maps
     (String, Protected_Block);

   type Port is
      record
         Remote_Thread : Unbounded_String;
         Remote_PI     : Unbounded_String;
      end record;

   package Ports is new Indefinite_Ordered_Maps (String, Port);

   type AADL_Thread is tagged
      record
         Name                 : Unbounded_String;
         Entry_Port_Name      : Unbounded_String;
         Protected_Block_Name : Unbounded_String;
         Output_Ports         : Ports.Map;
         Node                 : Option_Node.Option;
      end record;

   function To_Template (T : AADL_Thread) return Translate_Set;

   package AADL_Threads is new Indefinite_Ordered_Maps (String, AADL_Thread);

   type Taste_Concurrency_View is tagged
      record
         Threads : AADL_Threads.Map;
         Blocks  : Protected_Blocks.Map;
      end record;

   procedure Debug_Dump (CV     : Taste_Concurrency_View;
                         Output : File_Type);

   --  Set of constructs for transforming the AST into Template entities
   package ST_Blocks is new Indefinite_Vectors (Natural, Block_As_Template);

   type CV_As_Template is
      record
         Threads : Translate_Sets.Vector;
         Blocks  : ST_Blocks.Vector;
      end record;

   function Concurrency_View_Template (CV : Taste_Concurrency_View)
     return CV_As_Template;

end TASTE.Concurrency_View;
