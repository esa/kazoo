--  *************************** taste aadl parser ***********************  --
--  (c) 2019 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

--  Model of the Concurrency View

with Ada.Containers.Indefinite_Ordered_Maps,
     Ada.Strings.Unbounded,
     Ada.Strings.Equal_Case_Insensitive,
     Ada.Strings.Less_Case_Insensitive,
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

   function "="(Left, Right : Case_Insensitive_String) return Boolean
       renames Ada.Strings.Equal_Case_Insensitive;
   function "<"(Left, Right : Case_Insensitive_String) return Boolean
       renames Ada.Strings.Less_Case_Insensitive;

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
         Ref_Function    : Taste_Terminal_Function;
         Block_Provided  : Protected_Block_PIs.Map;
         --  Required interfaces are defined in Ref_Function
         Calling_Threads : String_Sets.Set;
         Node            : Option_Node.Option;
      end record;

   --  Data model for the template backends (templates_parser)
   type Block_As_Template is
      record
         Header               : Translate_Set;
         Protected_Provided   : Translate_Sets.Vector;
         Unprotected_Provided : Translate_Sets.Vector;
         Required             : Translate_Sets.Vector;
      end record;
   function Prepare_Block_Template (B : Protected_Block)
                                    return Block_As_Template;

   package Protected_Blocks is new Indefinite_Ordered_Maps
     (String, Protected_Block);

   type Thread_Port is
      record
         Name          : Unbounded_String;
         Remote_Thread : Unbounded_String;
         Remote_PI     : Unbounded_String;  -- Remote PI name
         RI            : Taste_Interface;
      end record;

   package Ports is new Indefinite_Ordered_Maps (String, Thread_Port);

   type AADL_Thread is tagged
      record
         Name                 : Unbounded_String;
         Partition_Name       : Unbounded_String;
         RCM                  : Unbounded_String;
         Need_Mutex           : Boolean := False;
         Entry_Port_Name      : Unbounded_String;
         Protected_Block_Name : Unbounded_String;
         Output_Ports         : Ports.Map;
         Node                 : Option_Node.Option;
         Priority,
         Dispatch_Offset_Ms,
         Stack_Size_In_Kb     : Unbounded_String := Null_Unbounded_String;
         PI                   : Taste_Interface; --  Contains period, etc.
      end record;

   function To_Template (T : AADL_Thread) return Translate_Set;

   package AADL_Threads is new Indefinite_Ordered_Maps
     (Case_Insensitive_String, AADL_Thread);

   type Partition_In_Port is
      record
         Port_Name, Thread_Name, Type_Name : Unbounded_String;
         Remote_Partition_Name : Unbounded_String; --  Other side
      end record;

   package Partition_In_Ports is
     new Indefinite_Ordered_Maps (String, Partition_In_Port);

   --  Output ports of partitions can be connected to more than one
   --  thread output port. A vector of thread is needed to hold the list
   type Partition_Out_Port is
      record
         Port_Name, Type_Name  : Unbounded_String;
         Connected_Threads     : String_Vectors.Vector;
         Remote_Partition_Name,
         Remote_Port_Name      : Unbounded_String; --  Other side
      end record;

   package Partition_Out_Ports is
     new Indefinite_Ordered_Maps (String, Partition_Out_Port);

   type CV_Partition is tagged
      record
         Deployment_Partition : Taste_Partition;
         Threads              : AADL_Threads.Map;
         Blocks               : Protected_Blocks.Map;
         In_Ports             : Partition_In_Ports.Map;
         Out_Ports            : Partition_Out_Ports.Map;
      end record;

   package CV_Partitions is new Indefinite_Ordered_Maps
     (Case_Insensitive_String, CV_Partition);

   --  A node may contain several partitions (in case of TSP)
   type CV_Node is tagged
      record
         Deployment_Node : Taste_Node;
         Partitions      : CV_Partitions.Map;
      end record;

   package CV_Nodes is new Indefinite_Ordered_Maps
     (Case_Insensitive_String, CV_Node);

   --  CV is made of a list of nodes, each containing a list of partitions
   --  Partitions contain threads and passive functions as created during
   --  Vertical transformation
   --  Nodes contain drivers, and nodes are connected via busses, but this
   --  information is already in the deployment view. It is not repeated here.
   type Taste_Concurrency_View is tagged
      record
         Configuration      : Taste_Configuration;
         Nodes              : CV_Nodes.Map;
         Deployment         : Complete_Deployment_View;
         Base_Template_Path : String_Holder;
         Base_Output_Path   : String_Holder;
      end record;

   procedure Debug_Dump (CV     : Taste_Concurrency_View;
                         Output : File_Type);

   --  Generate the concurrency view using templates
   procedure Generate_CV (CV : Taste_Concurrency_View);

end TASTE.Concurrency_View;
