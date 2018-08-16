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
pragma Unreferenced (TASTE.Concurrency_View);
use Ada.Strings.Unbounded,
    Ocarina.Types,
    TASTE.Parser_Utils,
    TASTE.Interface_View,
    TASTE.Deployment_View,
    TASTE.Data_View;

package TASTE.AADL_Parser is
   Interface_Root  : Node_Id := No_Node;
   Deployment_Root : Node_Id := No_Node;
   Dataview_Root   : Node_Id := No_Node;

   type TASTE_Model is tagged
      record
         Interface_View  : Complete_Interface_View;
         Deployment_View : Complete_Deployment_View;
         Data_View       : Taste_Data_View;
         Configuration   : Taste_Configuration;
      end record;

   function Parse_Project return TASTE_Model;
   function Find_Binding (Model : TASTE_Model;
                          F     : Unbounded_String)
                          return Option_Partition.Option;

   procedure Dump                  (Model : TASTE_Model);
   procedure Generate_Build_Script (Model : TASTE_Model);
   procedure Generate_Code         (Model : TASTE_Model);

private
   function Initialize return Taste_Configuration;
end TASTE.AADL_Parser;
