--  *************************** taste aadl parser ***********************  --
--  (c) 2017 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

--  Deployment View parser

with Ocarina,
     Ocarina.Types,
     Ada.Containers.Indefinite_Ordered_Maps,
     Ada.Containers.Indefinite_Vectors,
     Ada.Strings.Unbounded,
     --  Option_Type,
     Parser_Utils;

use Ocarina,
    Ocarina.Types,
    Ada.Containers,
    Ada.Strings.Unbounded,
    Parser_Utils;

package Deployment_View is

   use Option_UString;
   use Option_ULL;

   --  Exceptions specific to the deployment view
   Deployment_View_Error       : exception;
   Device_Driver_Error         : exception;
   Empty_Deployment_View_Error : exception;

   --  Initialize Ocarina and instantiate the deployment view, return root.
   function Initialize (Root : Node_Id) return Node_Id
   with Pre => Root /= No_Node;

   type Taste_Bus is
      record
         Name         : Unbounded_String;
         AADL_Package : Unbounded_String;
         Classifier   : Unbounded_String;
         Properties   : Property_Maps.Map;
      end record;

   package Taste_Busses is new Indefinite_Vectors (Natural, Taste_Bus);

   type Bus_Connection is
      record
         Source_Node : Unbounded_String;
         Source_Port : Unbounded_String;
         Bus_Name    : Unbounded_String;
         Dest_Node   : Unbounded_String;
         Dest_Port   : Unbounded_String;
      end record;

   package Bus_Connections is new Indefinite_Vectors (Natural, Bus_Connection);

   type Taste_Device_Driver is
      record
         Name                      : Unbounded_String;
         Package_Name              : Unbounded_String;
         Device_Classifier         : Unbounded_String;
         Associated_Processor_Name : Unbounded_String;
         Device_Configuration      : Unbounded_String;
         Accessed_Bus_Name         : Unbounded_String;
         Accessed_Port_Name        : Unbounded_String;
         ASN1_Filename             : Unbounded_String;
         ASN1_Typename             : Unbounded_String;
         ASN1_Module               : Unbounded_String;
      end record;

   package Taste_Drivers is
     new Indefinite_Vectors (Natural, Taste_Device_Driver);

   type Taste_Node is
      record
         Name    : Unbounded_String;
         Drivers : Taste_Drivers.Vector;
      end record;

   package Node_Maps is new Indefinite_Ordered_Maps (String, Taste_Node);

   type Complete_Deployment_View is tagged
      record
         Nodes       : Node_Maps.Map;
         Connections : Bus_Connections.Vector;
         Busses      : Taste_Busses.Vector;
      end record;

   --  Function to build up the Ada AST by transforming the one from Ocarina
   function AADL_To_Ada_DV (System : Node_Id) return Complete_Deployment_View;

   procedure Debug_Dump_DV (DV : Complete_Deployment_View);

end Deployment_View;
