--  *************************** taste aadl parser ***********************  --
--  (c) 2018 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

--  Data View parser

with Text_IO,
     Ada.Containers.Indefinite_Ordered_Maps,
     Ada.Strings.Unbounded,
     Ocarina,
     Ocarina.Types,
     TASTE.Parser_Utils;

use Text_IO,
    Ada.Containers,
    Ada.Strings.Unbounded,
    Ocarina,
    Ocarina.Types,
    TASTE.Parser_Utils;

package TASTE.Data_View is
   use String_Vectors;

   --  Exceptions specific to the Data View
   Data_View_Error   : exception;

   --  Extra files needed to parse the Data view (dependency hell)
   Data_View_AADL_Lib : String_Vectors.Vector := Empty_Vector &
                "aadl_project.aadl" &
                "taste_properties.aadl" &
                "communication_properties.aadl" &
                "timing_properties.aadl" &
                "programming_properties.aadl" &
                "memory_properties.aadl" &
                "base_types.aadl" &
                "data_model.aadl" &
                "deployment.aadl";

   type ASN1_File is
      record
         Path    : Unbounded_String;
         Modules : String_Vectors.Vector;
      end record;
   package ASN1_Maps is new Indefinite_Ordered_Maps (String, ASN1_File);

   type Taste_Data_View is tagged
      record
         ASN1_Files : ASN1_Maps.Map;
      end record;

   function Parse_Data_View (Dataview_Root : Node_Id) return Taste_Data_View
      with Pre => Dataview_Root /= No_Node;

   procedure Debug_Dump (DV : Taste_Data_View; Output : File_Type);

end TASTE.Data_View;
