with Text_IO; use Text_IO;
with Ada.Strings.Unbounded,
     Ada.Characters.Handling,
     Ada.Directories;

use Ada.Characters.Handling,
    Ada.Directories;

package body TASTE.Backend.Skeletons is
   procedure Generate (Model : TASTE_Model) is
      Template : constant IV_As_Template :=
        Interface_View_Template (Model.Interface_View);
      Prefix : constant String := Model.Configuration.Binary_Path.all
        & "templates/skeletons/";
      use Ada.Strings.Unbounded;
      type Output is (Header, Code);
      function Process_Interfaces (Interfaces : Interface_Vectors.Vector;
                                   Path       : String;
                                   Target     : Output) return Tag
      is
         Interfaces_Tag : Tag;
         Tmplt_Param : constant String :=
           Path & "interface-" & (if Target = Header then "header" else "body")
           & "-parameter.tmplt";
         Tmplt_Sign  : constant String := Path & "interface-signature.tmplt";
         Proceed : constant Boolean := Exists (Path)
           and then Kind (Path) = Directory
           and then Exists (Tmplt_Param) and then Exists (Tmplt_Sign);
      begin
         if not Proceed then
            return Interfaces_Tag;
         end if;
         for Each of Interfaces loop
            declare
               Pool   : Translate_Set := Each.Header;
               Params : Tag;
            begin
               for Param of Each.Params loop
                  declare
                     P : constant String := Parse (Tmplt_Param, Param);
                  begin
                     Params := Params & P;
                  end;
               end loop;
               Pool := Pool & Assoc ("Parameters", Params);
               declare
                  New_Interface : constant String := Parse (Tmplt_Sign, Pool);
               begin
                  Interfaces_Tag := Interfaces_Tag & New_Interface;
               end;
            end;
         end loop;
         return Interfaces_Tag;
      end Process_Interfaces;
   begin
      Put_Line ("=== Generate skeletons ===");
      for Each of Model.Interface_View.Flat_Functions loop
         declare
            Language   : constant String := Language_Spelling (Each);
            Path       : constant String := Prefix & To_Lower (Language) & "/";
            Hdr_Tmpl   : constant Translate_Set := +Assoc ("Name", Each.Name);
            Func_Tmpl  : constant Func_As_Template :=
              Template.Funcs.Element (To_String (Each.Name));
            PIs_Header : constant Tag :=
              Process_Interfaces (Func_Tmpl.Provided, Path, Header);
            RIs_Header : constant Tag :=
              Process_Interfaces (Func_Tmpl.Required, Path, Header);
            PIs_Body   : constant Tag :=
              Process_Interfaces (Func_Tmpl.Provided, Path, Code);
            RIs_Body   : constant Tag :=
              Process_Interfaces (Func_Tmpl.Required, Path, Code);
            Func_Hdr   : constant Translate_Set := Func_Tmpl.Header
              & Assoc ("Provided_Interfaces", PIs_Header)
              & Assoc ("Required_Interfaces", RIs_Header);
            Func_Body  : constant Translate_Set := Func_Tmpl.Header
              & Assoc ("Provided_Interfaces", PIs_Body)
              & Assoc ("Required_Interfaces", RIs_Body);
         begin
            if Size (PIs_Header) /= 0 or Size (RIs_Header) /= 0 then
               Put ("***  Generating ");
               Put_Line (Parse (Path & "header-filename.tmplt", Hdr_Tmpl));
               Put_Line (Parse (Path & "header.tmplt", Func_Hdr));
               Put ("***  Generating ");
               Put_Line (Parse (Path & "body-filename.tmplt", Hdr_Tmpl));
               Put_Line (Parse (Path & "body.tmplt", Func_Body));
            else
               Put_Line ("No skeletons for language " & Language & " !");
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
