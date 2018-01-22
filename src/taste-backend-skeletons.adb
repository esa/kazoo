with Text_IO; use Text_IO;
with Ada.Strings.Unbounded,
     Ada.Characters.Handling,
     Ada.Exceptions;

use Ada.Characters.Handling,
    Ada.Exceptions;

--  with TASTE.Backend.Skeletons.C;

package body TASTE.Backend.Skeletons is
   procedure Generate (Model : TASTE_Model) is
      Template : constant IV_As_Template :=
        Interface_View_Template (Model.Interface_View);
      Prefix : constant String := Model.Configuration.Binary_Path.all
        & "templates/skeletons/";
      use Ada.Strings.Unbounded;
   begin
      Put_Line ("=== Generate skeletons ===");
      for Each of Model.Interface_View.Flat_Functions loop
         declare
            Language  : constant String := Language_Spelling (Each);
            Path      : constant String := Prefix & To_Lower (Language) & "/";
            Hdr_Tmpl  : constant Translate_Set := +Assoc ("Name", Each.Name);
            Func_Tmpl : constant Func_As_Template :=
              Template.Funcs.Element (To_String (Each.Name));
            PIs       : Tag;
            RIs       : Tag;
            Func_Hdr  : Translate_Set := Func_Tmpl.Header;
         begin
            Put ("***  Generating ");
            Put_Line (Parse (Path & "header-filename.tmplt", Hdr_Tmpl));
            for PI of Func_Tmpl.Provided loop
               declare
                  Header : Translate_Set := PI.Header;
                  Params : Tag;
               begin
                  for Param of PI.Params loop
                     declare
                        P : constant String :=
                          Parse
                            (Path & "interface-header-parameter.tmplt", Param);
                     begin
                        Params := Params & P;
                     end;
                  end loop;
                  Header := Header & Assoc ("Parameters", Params);
                  declare
                     PI : constant String :=
                       Parse (Path & "interface-signature.tmplt", Header);
                  begin
                     PIs := PIs & PI;
                  end;
               end;
            end loop;
            Func_Hdr := Func_Hdr & Assoc ("Provided_Interfaces", PIs);
            for RI of Func_Tmpl.Required loop
               declare
                  Header : Translate_Set := RI.Header;
                  Params : Tag;
               begin
                  for Param of RI.Params loop
                     declare
                        P : constant String := Parse
                            (Path & "interface-header-parameter.tmplt", Param);
                     begin
                        Params := Params & P;
                     end;
                  end loop;
                  Header := Header & Assoc ("Parameters", Params);
                  declare
                     RI : constant String :=
                       Parse (Path & "interface-signature.tmplt", Header);
                  begin
                     RIs := RIs & RI;
                  end;
               end;
            end loop;
            Func_Hdr := Func_Hdr & Assoc ("Required_Interfaces", RIs);
            Put_Line (Parse (Path & "header.tmplt", Func_Hdr));
            Put ("***  Generating ");
            Put_Line (Parse (Path & "body-filename.tmplt", Hdr_Tmpl));
         exception
            when E : others =>
               Put_Line ("no skeletons for language " & Language & " !");
               if Language /= "GUI" then
                  Put_Line (Exception_Message (E));
               end if;
         end;
      end loop;
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
      use Func_Maps;
      use Ada.Strings.Unbounded;
      Result : IV_As_Template;
   begin
      for Each of IV.Flat_Functions loop
         Result.Funcs.Insert (Key      => To_String (Each.Name),
                              New_Item => Func_Template (Each));
      end loop;
      return Result;
   end Interface_View_Template;

end TASTe.Backend.Skeletons;
