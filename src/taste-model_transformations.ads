with TASTE.AADL_Parser;
use  TASTE.AADL_Parser;

package TASTE.Model_Transformations is
   --  Transform: apply TASTE "Preprocessing" on IV/DV and return a new model
   --  Following transformations are done:
   --  * Add "Poll" cyclic PI to GUI components
   --  * if the function mixes cyclic/spo PI, create separate functions with
   --    a single PI for each and change the existing ones to Protected
   --  * For each (Un)protected RI of a function, add RI to the newly created
   --    functions (see point above)
   --  * Set "Ignore params" flag on interfaces that run on the same node (?)
   --  * Create a Taste API per node
   --  * Create Timer manager functions
   function Transform (Model : TASTE_Model) return TASTE_Model;
   Transformation_Error : exception;
end TASTE.Model_Transformations;
