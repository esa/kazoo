with Text_IO; use Text_IO;

--  with TASTE.Backend.Skeletons.C;

package body TASTE.Backend.Skeletons is
   procedure Generate (Model : TASTE_Model) is
      dummy_Template : constant IV_As_Template :=
        Interface_View_Template (Model.Interface_View);
   begin
      Put_Line ("=== Generate skeletons ===");
--             case Each.Language is
--               when Language_C =>
--                  TASTE.Backend.Skeletons.C.Generate (Model.Configuration,
--                                                      Template);
--               when others =>
--                  Put_Line (Each.Language'Img & "Not supported yet");
--            end case;
--         end;
--      end loop;
   end Generate;

   function Parameter_Template (Param : ASN1_Parameter) return Translate_Set is
     (+Assoc ("Type", Param.Sort) & Assoc ("Name", Param.Name)
     & Assoc ("Direction", Param.Direction'Img));

   function Interface_Template (TI : Taste_Interface)
                                return Interface_As_Template
   is
      use Template_Vectors;
      Result : Interface_As_Template;
   begin
      Result.Header :=  +Assoc ("Name",             TI.Name)
                        & Assoc ("Parent_Function", TI.Parent_Function);
      for Each of TI.Params loop
         Result.Params := Result.Params & Parameter_Template (Each);
      end loop;
      return Result;
   end Interface_Template;

   function Func_Template (F : Taste_Terminal_Function) return Func_As_Template
   is
      use Interface_Vectors;
      Result : Func_As_Template;
   begin
      Result.Header := +Assoc ("Name", F.Name)
                       & Assoc ("Language", F.Language'Img);
      for Each of F.Provided loop
         Result.Provided := Result.Provided & Interface_Template (Each);
      end loop;
      for Each of F.Required loop
         Result.Required := Result.Required & Interface_Template (Each);
      end loop;
      return Result;
   end Func_Template;

   function Interface_View_Template (IV : Complete_Interface_View)
                                     return IV_As_Template is
      use Func_Vectors;
      Result : IV_As_Template;
   begin
      for Each of IV.Flat_Functions loop
         Result.Funcs := Result.Funcs & Func_Template (Each);
      end loop;
      return Result;
   end Interface_View_Template;

end TASTe.Backend.Skeletons;
