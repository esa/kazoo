--  *************************** taste aadl parser ***********************  --
--  (c) 2018 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

--  Model of the Concurrency View

with Ada.Containers.Indefinite_Ordered_Maps,
     Ada.Strings.Unbounded,
     TASTE.Parser_Utils,
     --  TASTE.AADL_Parser,
     TASTE.Interface_View;

use Ada.Containers,
    Ada.Strings.Unbounded,
    TASTE.Parser_Utils,
    --  TASTE.AADL_Parser,
    TASTE.Interface_View;

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

   type Protected_Block is
      record
         Name            : Unbounded_String;
         Provided        : Protected_Block_PIs.Map;
         Required        : Interfaces_Maps.Map;
         Calling_Threads : String_Vectors.Vector;
      end record;

   package Protected_Blocks is new Indefinite_Ordered_Maps
     (String, Protected_Block);

   type Port is
      record
         Remote_Thread : Unbounded_String;
         Remote_PI     : Unbounded_String;
      end record;

   package Ports is new Indefinite_Ordered_Maps (String, Port);

   type AADL_Thread is
      record
         Name                 : Unbounded_String;
         Entry_Port_Name      : Unbounded_String;
         Protected_Block_Name : Unbounded_String;
         Output_Ports         : Ports.Map;
      end record;

   package AADL_Threads is new Indefinite_Ordered_Maps (String, AADL_Thread);

   type Taste_Concurrency_View is
      record
         Threads : AADL_Threads.Map;
         Blocks  : Protected_Blocks.Map;
      end record;

end TASTE.Concurrency_View;
