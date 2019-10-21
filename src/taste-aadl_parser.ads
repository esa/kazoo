--  ************************ TASTE AADL Parser **************************  --

--  (c) 2017 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

with Ada.Strings.Unbounded,
     Ocarina.Types,
     TASTE.Parser_Utils,
     TASTE.Interface_View,
     TASTE.Deployment_View,
     TASTE.Concurrency_View,
     TASTE.Data_View;

use Ada.Strings.Unbounded,
    Ocarina.Types,
    TASTE.Parser_Utils,
    TASTE.Interface_View,
    TASTE.Deployment_View,
    TASTE.Concurrency_View,
    TASTE.Data_View;

package TASTE.AADL_Parser is
   Interface_Root  : Node_Id := No_Node;
   Deployment_Root : Node_Id := No_Node;
   Dataview_Root   : Node_Id := No_Node;

   --  Definition of the data model of a TASTE system
   type TASTE_Model is tagged
      record
         Interface_View   : Complete_Interface_View;
         Deployment_View  : Deployment_View_Holder;
         Data_View        : Taste_Data_View;
         Concurrency_View : Taste_Concurrency_View;
         Configuration    : Taste_Configuration;
      end record;

   function Parse_Project return TASTE_Model;

   --  Transform: add Poll cyclic in GUIs, manage timers and taste api
   --  This function can be called if there is a deployment view
   function Transform (Model : TASTE_Model) return TASTE_Model;

   --  Create the concurrency view and apply the templates for code generation
   procedure Add_Concurrency_View (Model : in out TASTE_Model)
     with Pre => not Model.Deployment_View.Is_Empty;

   function Find_Binding (Model : TASTE_Model;
                          F     : Unbounded_String)
                          return Option_Partition.Option;

   procedure Dump                  (Model : TASTE_Model);
   procedure Generate_Build_Script (Model : TASTE_Model);
   procedure Generate_Code         (Model : TASTE_Model);

private
   function Initialize return Taste_Configuration;

   --  Perform various processing on a function. Return a map of possibly
   --  created new functions, to be added to the new Model
   function Process_Function (F : in out Taste_Terminal_Function)
      return Function_Maps.Map;
end TASTE.AADL_Parser;
