with Templates_Parser,
     TASTE.AADL_Parser;

use Templates_Parser,
    TASTE.AADL_Parser;

package TASTE.Backend.Code_Generators is
   procedure Generate (Model : TASTE_Model);
   ACG_Error : exception;

   type IV_As_Template is
      record
         Funcs : Func_Maps.Map;
         --  Connections:
         Callers, Callees, PI_Names, RI_Names : Vector_Tag;
      end record;

   --  Set of functions translating the AST into Templates_Parser mappings

   function CP_Template (F : Taste_Terminal_Function)
                         return Translate_Set;
   function Function_Makefile_Template (F       : Taste_Terminal_Function;
                                        Modules : Tag;
                                        Files   : Tag)
                                        return Translate_Set;
   function Interface_View_Template (IV : Complete_Interface_View)
                                     return IV_As_Template;

end TASTE.Backend.Code_Generators;
