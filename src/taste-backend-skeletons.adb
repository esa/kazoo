with Text_IO; use Text_IO;
with Ada.Strings.Unbounded,
     Ada.Characters.Handling,
     Ada.Containers.Ordered_Sets,
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
      Output_File : File_Type;
      Template    : constant IV_As_Template :=
        Interface_View_Template (Model.Interface_View);

      Prefix : constant String := Model.Configuration.Binary_Path.all
        & "templates/skeletons/";

      use Ada.Strings.Unbounded;
      type Output is (Header, Code);

      --  Function checking that all templates files are available to support
      --  a given language (based on the directory name).
      function Is_Template_Present (Path : String) return Boolean is
        (Exists (Path) and then Kind (Path) = Directory and then
         Exists (Path & "interface-header.tmplt")       and then
         Exists (Path & "interface-body.tmplt")         and then
         Exists (Path & "header.tmplt")                 and then
         Exists (Path & "body.tmplt")                   and then
         Exists (Path & "makefile.tmplt")               and then
         Exists (Path & "body-filename.tmplt")          and then
         Exists (Path & "header-filename.tmplt"));

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

      --  Return a Tag list of ASN.1 Files
      function Get_ASN1_File_List return Tag is
         Result : Tag;
      begin
         for Each of Model.Data_View.ASN1_Files loop
            Result := Result & Each.Path;
         end loop;
         return Result;
      end Get_ASN1_File_List;

      --  Generate the content of the Makefile per function
      function Function_Makefile (Path    : String;
                                  Content : Translate_Set) return String is
         Tmplt_Makefile : constant String := Path & "makefile.tmplt";
      begin
         return Parse (Tmplt_Makefile, Content);
      end Function_Makefile;

      function CP_To_ASN1 (Content : Translate_Set) return String is
         Tmplt_CP : constant String := Prefix & "context_parameters.tmplt";
      begin
         return Parse (Tmplt_CP, Content);
      end CP_To_ASN1;

      --  Generate string for a global Makefile (processing all functions)
      --  The template contains a set of languages, and a list of
      --  combined function name/language
      function Global_Makefile return String is
         package Languages_Set is new Ordered_Sets (Unbounded_String);
         use Languages_Set;
         Languages        : Set;
         Unique_Languages : Tag;
         Functions_Tag    : Vector_Tag;
         Language_Tag     : Vector_Tag;
         Is_Type_Tag      : Vector_Tag;
         Content_Set      : Translate_Set;
         Tmplt            : constant String := Prefix & "makefile.tmplt";
      begin
         if not Exists (Tmplt) then
            raise Skeleton_Error with "Missing makefile.tmplt";
         end if;
         for Each of Model.Interface_View.Flat_Functions loop
            Languages := Languages or To_Set (US (Language_Spelling (Each)));
            Functions_Tag := Functions_Tag & Each.Name;
            Language_Tag  := Language_Tag & Language_Spelling (Each);
            Is_Type_Tag   := Is_Type_Tag & Each.Is_Type;
         end loop;
         for Each of Languages loop
            Unique_Languages := Unique_Languages & To_String (Each);
         end loop;
         Content_Set := +Assoc  ("Function_Names",   Functions_Tag)
                        & Assoc ("Language",         Language_Tag)
                        & Assoc ("Is_Type",          Is_Type_Tag)
                        & Assoc ("Unique_Languages", Unique_Languages)
                        & Assoc ("ASN1_Files",       Get_ASN1_File_List)
                        & Assoc ("ASN1_Modules",     Get_Module_List);
         return Parse (Tmplt, Content_Set);
      end Global_Makefile;

      function Process_Interfaces (Interfaces : Interface_Vectors.Vector;
                                   Path       : String;
                                   Target     : Output) return Tag
      is
         Result : Tag;
         Tmplt_Sign  : constant String :=
            Path & "interface-" & (if Target = Header then "header"
                                                      else "body") & ".tmplt";
      begin
         for Each of Interfaces loop
            Result := Result & String'(Parse (Tmplt_Sign, Each.Header));
         end loop;
         return Result;
      end Process_Interfaces;
   begin
      Put_Info ("=== Generate skeletons ===");
      for Each of Model.Interface_View.Flat_Functions loop
         declare
            Language   : constant String := Language_Spelling (Each);
            Path       : constant String := Prefix & To_Lower (Language) & "/";
            Proceed    : constant Boolean := Is_Template_Present (Path);
            Hdr_Tmpl   : constant Translate_Set :=
                +Assoc ("Name", Each.Name)
                & Assoc ("Is_Type", Each.Is_Type)
                & Assoc ("Instance_Of", Each.Instance_Of.Value_Or (US ("")));
            Make_Tmpl  : constant Translate_Set := Function_Makefile_Template
                                        (F       => Each,
                                         Modules => Get_Module_List,
                                         Files   => Get_ASN1_File_List);
            Make_Text  : constant String := (if Proceed
                             then Function_Makefile (Path, Make_Tmpl) else "");
            --  Associations for (optional) context parameters:
            CP_Tmpl    : constant Translate_Set := CP_Template (F => Each);
            CP_Text    : constant String := CP_To_ASN1 (CP_Tmpl);
            CP_File    : constant String := "Context-"
                                            & To_String (Each.Name)
                                            & ".asn";

            Func_Tmpl  : constant Func_As_Template :=
              Template.Funcs.Element (To_String (Each.Name));

            Func_Hdr   : constant Translate_Set :=
              (if Proceed then Func_Tmpl.Header
               & Assoc ("Provided_Interfaces",
                 Process_Interfaces (Func_Tmpl.Provided, Path, Header))
               & Assoc ("Required_Interfaces",
                 Process_Interfaces (Func_Tmpl.Required, Path, Header))
               & Assoc ("ASN1_Modules", Get_Module_List)
               & Assoc ("ASN1_Files", Get_ASN1_File_List)
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
            Output_Base : constant String :=
                            Model.Configuration.Output_Dir.all
                            & "/" & To_Lower (To_String (Each.Name))
                            & "/" & Language & "/";
            Output_Src  : constant String := Output_Base & "src/";
            --  Get header and body filenames from templates
            Header_File : constant String := Strip_String
                            (if Proceed then Parse
                               (Path & "header-filename.tmplt", Hdr_Tmpl)
                             else "");
            Body_File   : constant String := Strip_String
                            (if Proceed then Parse
                               (Path & "body-filename.tmplt", Hdr_Tmpl)
                             else "");
            Make_File   : constant String := "Makefile";
         begin
            if Proceed then
               --  Create directory tree (output/function/language/src)
               Create_Path (Output_Src);
               if Header_File /= "" then
                  Put_Info ("Generating " & Output_Src & Header_File);
                  Create (File => Output_File,
                          Mode => Out_File,
                          Name => Output_Src & Header_File);
                  Put_Line (Output_File, Header_Text);
                  Close (Output_File);
               else
                  Put_Info ("No header file needed for function "
                             & To_String (Each.Name));
               end if;
               if Body_File /= "" and then not Exists (Output_Src & Body_File)
               then
                  Put_Info ("Generating " & Body_File);
                  Create (File => Output_File,
                          Mode => Out_File,
                          Name => Output_Src & Body_File);
                  Put_Line (Output_File, Body_Text);
                  Close (Output_File);
               else
                  Put_Info ("No body file generated for function "
                            & To_String (Each.Name));
               end if;
               Put_Info ("Generating " & Make_File & " for function "
                         & To_String (Each.Name));
               Create (File => Output_File,
                       Mode => Out_File,
                       Name => Output_Base & Make_File);
               Put_Line (Output_File, Make_Text);
               Close (Output_File);
               --  Generate context parameters if any
               if not Each.Context_Params.Is_Empty then
                  Put_Info ("Generating " & CP_File);
                  Create (File => Output_File,
                          Mode => Out_File,
                          Name => Output_Base & CP_File);
                  Put_Line (Output_File, CP_Text);
                  Close (Output_File);
               end if;
            else
               Put_Info ("Ignoring function " & To_String (Each.Name));
            end if;
         exception
            when E : End_Error
               | Text_IO.Use_Error =>
               if Is_Open (Output_File) then
                  Close (Output_File);
               end if;
               raise Skeleton_Error with "Generation of skeleton for function "
                 & To_String (Each.Name) & " failed : "
                 & Exception_Message (E);
         end;
      end loop;
      Put_Info ("Generating global Makefile");
      Create (File => Output_File,
              Mode => Out_File,
              Name => Model.Configuration.Output_Dir.all & "/" & "Makefile");
      Put_Line (Output_File, Global_Makefile);
      Close (Output_File);
   end Generate;

   --  Context Parameters
   function CP_Template (F : Taste_Terminal_Function) return Translate_Set is
      use Ada.Strings.Unbounded;
      package Sort_Set is new Ordered_Sets (Unbounded_String);
      use Sort_Set;
      Sorts_Set     : Set;
      Unique_Sorts : Vector_Tag;
      Corr_Module  : Vector_Tag;
      Names        : Vector_Tag;
      Sorts        : Vector_Tag;
      ASN1_Modules : Vector_Tag;
      Values       : Vector_Tag;
   begin
      for Each of F.Context_Params loop
         if not Sorts_Set.Contains (Each.Sort) then
            --  Build up a set of unique types, needed for the IMPORTS section
            --  in the ASN.1 module
            Sorts_Set.Insert (Each.Sort);
            Unique_Sorts := Unique_Sorts & Each.Sort;
            Corr_Module  := Corr_Module & Each.ASN1_Module;
         end if;
         Names        := Names        & Each.Name;
         Sorts        := Sorts        & Each.Sort;
         ASN1_Modules := ASN1_Modules & Each.ASN1_Module;
         Values       := Values       & Each.Default_Value;
      end loop;
      return Result : constant Translate_Set := +Assoc ("Name",  F.Name)
                                      & Assoc ("Sort_Set",       Unique_Sorts)
                                      & Assoc ("Module_Set",     Corr_Module)
                                      & Assoc ("CP_Name",        Names)
                                      & Assoc ("CP_Sort",        Sorts)
                                      & Assoc ("CP_ASN1_Module", ASN1_Modules)
                                      & Assoc ("CP_Value",       Values);
   end CP_Template;

   --  Makefiles need the function name and the list of ASN.1 files/modules
   function Function_Makefile_Template (F       : Taste_Terminal_Function;
                                        Modules : Tag;
                                        Files   : Tag) return Translate_Set
   is (Translate_Set'(+Assoc  ("Name",         F.Name)
                      & Assoc ("ASN1_Files",   Files)
                      & Assoc ("ASN1_Modules", Modules))
                      & Assoc ("Is_Type",      F.Is_Type)
                      & Assoc ("Instance_Of",
                                F.Instance_Of.Value_Or (US (""))));

   function Interface_Template (TI : Taste_Interface)
                                return Interface_As_Template
   is
      use Template_Vectors;
      Result           : Interface_As_Template;
      Param_Names      : Vector_Tag;
      Param_Types      : Vector_Tag;
      Param_Directions : Vector_Tag;
   begin
      Result.Header :=  +Assoc  ("Name",            TI.Name)
                        & Assoc ("Kind",            TI.RCM'Img)
                        & Assoc ("Parent_Function", TI.Parent_Function);
      for Each of TI.Params loop
         --  Result.Params    := Result.Params & Parameter_Template (Each, TI);
         Param_Names      := Param_Names & Each.Name;
         Param_Types      := Param_Types & Each.Sort;
         Param_Directions := Param_Directions & Each.Direction'Img;
      end loop;
      Result.Header := Result.Header
                       & Assoc ("Param_Names",      Param_Names)
                       & Assoc ("Param_Types",      Param_Types)
                       & Assoc ("Param_Directions", Param_Directions);
      return Result;
   end Interface_Template;

   function Func_Template (F : Taste_Terminal_Function) return Func_As_Template
   is
      use Interface_Vectors;
      use Ctxt_Params;
      Result             : Func_As_Template;
      List_Of_PIs        : Tag;
      List_Of_RIs        : Tag;
      List_Of_Sync_PIs   : Tag;
      List_Of_ASync_PIs  : Tag;
      List_Of_Sync_RIs   : Tag;
      List_Of_ASync_RIs  : Tag;
      Timers             : Tag;
      Property_Names     : Vector_Tag;
      Property_Values    : Vector_Tag;
      CP_Names           : Vector_Tag;   -- For Context Parameters
      CP_Types           : Vector_Tag;   -- For Context Parameters
      Interface_Tmplt    : Interface_As_Template;
   begin
      Result.Header := +Assoc ("Name", F.Name)
        & Assoc ("Language", Language_Spelling (F))
        & Assoc ("Has_Context", (Length (F.Context_Params) > 0));

      --  Add context parameters details
      for Each of F.Context_Params loop
         CP_Names := CP_Names & Each.Name;
         CP_Types := CP_Types & Each.Sort;
      end loop;

      --  Add list of all PI names (both synchronous and asynchronous)
      for Each of F.Provided loop
         Interface_Tmplt := Interface_Template (Each);
         Interface_Tmplt.Header := Interface_Tmplt.Header
                                   & Assoc ("Direction", "PI");
         Result.Provided := Result.Provided & Interface_Tmplt;
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
         Interface_Tmplt := Interface_Template (Each);
         Interface_Tmplt.Header := Interface_Tmplt.Header
                                   & Assoc ("Direction", "RI");
         Result.Required := Result.Required & Interface_Tmplt;
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
        & Assoc ("CP_Names",          CP_Names)
        & Assoc ("CP_Types",          CP_Types)
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
