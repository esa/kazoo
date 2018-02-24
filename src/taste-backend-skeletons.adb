with Text_IO; use Text_IO;
with Ada.Strings.Unbounded,
     Ada.Characters.Handling,
     Ada.Exceptions,
     Ada.Directories,
     TASTE.Parser_Utils;

use Ada.Characters.Handling,
    Ada.Exceptions,
    Ada.Directories,
    TASTE.Parser_Utils;

--  This package covers the generation of skeletons for all supported languages
--  There is no code that is specific to one particular language. The package
--  looks for a sub-directory with the name of the language and checks that all
--  skeleton-related template files are present. Then it fills the Template
--  mappings and generate the corresponding code.

package body TASTE.Backend.Skeletons is
   procedure Generate (Model : TASTE_Model) is
      Template : constant IV_As_Template :=
        Interface_View_Template (Model.Interface_View);

      Prefix : constant String := Model.Configuration.Binary_Path.all
        & "templates/skeletons/";

      use Ada.Strings.Unbounded;
      type Output is (Header, Code);

      --  Function checking that all templates files are available to support
      --  a given language (based on the directory name).
      function Is_Template_Present (Path : String) return Boolean is
        (Exists (Path) and then Kind (Path) = Directory and then
         Exists (Path & "interface-signature.tmplt") and then
         Exists (Path & "header.tmplt") and then
         Exists (Path & "body.tmplt") and then
         Exists (Path & "body-filename.tmplt") and then
         Exists (Path & "header-filename.tmplt") and then
         Exists (Path & "interface-body-parameter.tmplt") and then
         Exists (Path & "interface-header-parameter.tmplt"));

      function Process_Interfaces (Interfaces : Interface_Vectors.Vector;
                                   Path       : String;
                                   Target     : Output) return Tag
      is
         Interfaces_Tag : Tag;
         Tmplt_Param : constant String :=
           Path & "interface-" & (if Target = Header then "header" else "body")
           & "-parameter.tmplt";
         Tmplt_Sign  : constant String := Path & "interface-signature.tmplt";
      begin
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

      --  Return a Tag list of ASN.1 Modules for the skeleton headers
      function Get_Module_List return Tag is
         Result : Tag;
      begin
         for Each of Model.Data_View.ASN1_Files loop
            for Module of Each.Modules loop
               Result := Result & Module.Name;
            end loop;
         end loop;
         return Result;
      end Get_Module_List;

   begin
      Put_Info ("=== Generate skeletons ===");
      for Each of Model.Interface_View.Flat_Functions loop
         declare
            Language   : constant String := Language_Spelling (Each);
            Path       : constant String := Prefix & To_Lower (Language) & "/";
            Proceed    : constant Boolean := Is_Template_Present (Path);
            Hdr_Tmpl   : constant Translate_Set := +Assoc ("Name", Each.Name);

            Func_Tmpl  : constant Func_As_Template :=
              Template.Funcs.Element (To_String (Each.Name));

            Func_Hdr   : constant Translate_Set :=
              (if Proceed then Func_Tmpl.Header
               & Assoc ("Provided_Interfaces",
                 Process_Interfaces (Func_Tmpl.Provided, Path, Header))
               & Assoc ("Required_Interfaces",
                 Process_Interfaces (Func_Tmpl.Required, Path, Header))
               & Assoc ("ASN1_Modules", Get_Module_List)
               else Null_Set);

            Header_Text : constant String :=
             (if Proceed then Parse (Path & "header.tmplt", Func_Hdr) else "");

            Func_Body  : constant Translate_Set :=
              (if Proceed then Func_Tmpl.Header
              & Assoc ("Provided_Interfaces",
                       Process_Interfaces (Func_Tmpl.Provided, Path, Code))
              & Assoc ("Required_Interfaces",
                 Process_Interfaces (Func_Tmpl.Required, Path, Code))
               else Null_Set);
            Body_Text   : constant String :=
                            (if Proceed
                             then Parse (Path & "body.tmplt", Func_Body)
                             else "");
            Output_Src  : constant String :=
                            Model.Configuration.Output_Dir.all
                            & "/" & To_Lower (To_String (Each.Name))
                            & "/" & Language
                            & "/" & "src" & "/";
            --  Get header and body filenames from templates
            Header_File : constant String :=
                            (if Proceed then Parse
                               (Path & "header-filename.tmplt", Hdr_Tmpl)
                             else "");
            Body_File   : constant String :=
                            (if Proceed then Parse
                               (Path & "body-filename.tmplt", Hdr_Tmpl)
                             else "");
            Output      : File_Type;
         begin
            if Proceed then
               --  Create directory tree (output/function/language/src)
               Create_Path (Output_Src);
               Put_Info ("Generating " & Header_File);
               Create (File => Output,
                       Mode => Out_File,
                       Name => Output_Src & Header_File);
               Put_Line (Output, Header_Text);
               Close (Output);
               if not Exists (Output_Src & Body_File) then
                  Put_Info ("Generating " & Body_File);
                  Create (File => Output,
                          Mode => Out_File,
                          Name => Output_Src & Body_File);
                  Put_Line (Output, Body_Text);
                  Close (Output);
               else
                  Put_Info (Body_File & " already exists, ignoring");
               end if;
            else
               Put_Info ("Ignoring function " & To_String (Each.Name));
            end if;
         exception
            when E : End_Error
               | Text_IO.Use_Error =>
               if Is_Open (Output) then
                  Close (Output);
               end if;
               raise Skeleton_Error with "Generation of skeleton for function "
                 & To_String (Each.Name) & " failed : "
                 & Exception_Message (E);
         end;
      end loop;
   end Generate;

   function Parameter_Template (Param : ASN1_Parameter; TI : Taste_Interface)
       return Translate_Set
   is
     (+Assoc ("Type", Param.Sort) & Assoc ("Name", Param.Name)
     & Assoc ("Interface_Kind", TI.RCM'Img)
     & Assoc ("Direction", Param.Direction'Img));

   function Interface_Template (TI : Taste_Interface)
                                return Interface_As_Template
   is
      use Template_Vectors;
      Result : Interface_As_Template;
   begin
      Result.Header :=  +Assoc ("Name",             TI.Name)
                        & Assoc ("Kind",            TI.RCM'Img)
                        & Assoc ("Parent_Function", TI.Parent_Function);
      for Each of TI.Params loop
         Result.Params := Result.Params & Parameter_Template (Each, TI);
      end loop;
      return Result;
   end Interface_Template;

   function Func_Template (F : Taste_Terminal_Function) return Func_As_Template
   is
      use Interface_Vectors;
      use Ctxt_Params;
      Result            : Func_As_Template;
      List_Of_PIs       : Tag;
      List_Of_RIs       : Tag;
      List_Of_Sync_PIs  : Tag;
      List_Of_ASync_PIs : Tag;
      List_Of_Sync_RIs  : Tag;
      List_Of_ASync_RIs : Tag;
      Timers            : Tag;
      Property_Names    : Vector_Tag;
      Property_Values   : Vector_Tag;
   begin
      Result.Header := +Assoc ("Name", F.Name)
        & Assoc ("Language", Language_Spelling (F))
        & Assoc ("Has_Context", (Length (F.Context_Params) > 0));

      --  Add list of all PI names (both synchronous and asynchronous)
      for Each of F.Provided loop
         Result.Provided := Result.Provided & Interface_Template (Each);
         List_Of_PIs     := List_Of_PIs & Each.Name;
         case Each.RCM is
            when Cyclic_Operation | Sporadic_Operation =>
               List_Of_ASync_PIs := List_Of_ASync_PIs & Each.Name;
            when others =>
               List_Of_Sync_PIs := List_Of_Sync_PIs & Each.Name;
         end case;
      end loop;

      --  Add list of all RI names (both synchronous and asynchronous)
      for Each of F.Required loop
         Result.Required := Result.Required & Interface_Template (Each);
         List_Of_RIs     := List_Of_RIs & Each.Name;
         case Each.RCM is
            when Cyclic_Operation | Sporadic_Operation =>
               List_Of_ASync_RIs := List_Of_ASync_RIs & Each.Name;
            when others =>
               List_Of_Sync_RIs := List_Of_Sync_RIs & Each.Name;
         end case;
      end loop;

      --  Add list of timers (names)
      for Each of F.Timers loop
         Timers := Timers & Each;
      end loop;

      --  Add all user-defined properties
      for Each of F.User_Properties loop
         Property_Names  := Property_Names & Each.Name;
         Property_Values := Property_Values & Each.Value;
      end loop;

      --  Setup the mapping for the template
      Result.Header := Result.Header
        & Assoc ("List_Of_PIs",       List_Of_PIs)
        & Assoc ("List_Of_RIs",       List_Of_RIs)
        & Assoc ("List_Of_Sync_PIs",  List_Of_Sync_PIs)
        & Assoc ("List_Of_Sync_RIs",  List_Of_Sync_RIs)
        & Assoc ("List_Of_ASync_PIs", List_Of_ASync_PIs)
        & Assoc ("List_Of_ASync_RIs", List_Of_ASync_RIs)
        & Assoc ("Property_Names",    Property_Names)
        & Assoc ("Property_Values",   Property_Values)
        & Assoc ("Is_Type",           F.Is_Type)
        & Assoc ("Instance_Of",       F.Instance_Of.Value_Or (US ("")))
        & Assoc ("Timers",            Timers);
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
end TASTE.Backend.Skeletons;
