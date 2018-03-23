with --  TASTE.Interface_View,
     TASTE.AADL_Parser;

use -- TASTE.Interface_View,
    TASTE.AADL_Parser;

package TASTE.Semantic_Check is
   procedure Check_Model (Model : TASTE_Model);
   Semantic_Error : exception;

end TASTE.Semantic_Check;
