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
   Interface_Root,
   Deployment_Root,
   Dataview_Root : Node_Id := No_Node;

   --  ConcurrencyView_Properties.aadl is parsed but not analyzed,
   --  as it contains reference to the system threads which have not
   --  been created yet. The backend templates get access to the values.
   Concurrency_Properties_Root : Node_Id := No_Node;

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
   procedure Preprocessing (Model : in out TASTE_Model)
     with Pre => not Model.Deployment_View.Is_Empty;

   --  Create the concurrency view and apply the templates for code generation
   procedure Add_Concurrency_View (Model : in out TASTE_Model)
     with Pre => not Model.Deployment_View.Is_Empty;

   --  Parse the ConcurrencyView_Properties.aadl file to extract user-defined
   --  thread priorities, dispatch offset, stack sizes. Parsing is done at
   --  AST level only, the model is not semantically checked because at this
   --  point in the parsing the actual set of thread has not been computed,
   --  so the AADL file references non-existing artefacts. There can be
   --  reference to threads that will not be created at all, in which case
   --  they can be ignored or reported to the user for information.
   procedure Add_CV_Properties (Model : in out TASTE_Model);

   function Find_Binding (Model : TASTE_Model;
                          F     : Unbounded_String)
                          return Option_Partition.Option;

   procedure Dump                  (Model : TASTE_Model);
   procedure Generate_Build_Script (Model : TASTE_Model);
   procedure Generate_Code         (Model : TASTE_Model);

private
   procedure Build_TASTE_AST (Model : out TASTE_Model);
   procedure Find_Shared_Libraries (Model : out TASTE_Model);

   --  Perform various processing on a function. Return a map of possibly
   --  created new functions, to be added to the new Model
   function Process_Function (F : in out Taste_Terminal_Function)
      return Function_Maps.Map;
end TASTE.AADL_Parser;
