with Ada.Containers.Indefinite_Vectors,
     Ada.Containers.Indefinite_Ordered_Maps,
     Templates_Parser,
     TASTE.AADL_Parser;

use Ada.Containers,
    Templates_Parser,
    TASTE.AADL_Parser;

package TASTE.Backend.Code_Generators is
   procedure Generate (Model : TASTE_Model);
   ACG_Error : exception;

   package Template_Vectors is new Indefinite_Vectors (Natural, Translate_Set);

   package ST_Interfaces is new Indefinite_Vectors (Natural, Translate_Set);

   type Func_As_Template is
      record
         Header   : Translate_set;
         Provided : ST_Interfaces.Vector;
         Required : ST_Interfaces.Vector;
      end record;

   package Func_Maps is new Indefinite_Ordered_Maps (String, Func_As_Template);

   type IV_As_Template is
      record
         Funcs : Func_Maps.Map;
      end record;

   --  Set of functions translating the AST into Templates_Parser mappings
   function Func_Template (F : Taste_Terminal_Function)
                           return Func_As_Template;
   function CP_Template (F : Taste_Terminal_Function) return Translate_Set;
   function Function_Makefile_Template (F       : Taste_Terminal_Function;
                                        Modules : Tag;
                                        Files   : Tag) return Translate_Set;
   function Interface_View_Template (IV : Complete_Interface_View)
                                     return IV_As_Template;

end TASTE.Backend.Code_Generators;
