--  *************************** taste aadl parser ***********************  --
--  (c) 2019 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

--  Model of the Concurrency View

with TASTE.AADL_Parser;
use  TASTE.AADL_Parser;

package TASTE.Dump is

   Dump_Error : exception;

   --  Dump input files (interface, data, deployment)
   --  using the templates in the templates/dump/* subfolders
   procedure Dump_Input_Model (Model : TASTE_Model);

end TASTE.Dump;
