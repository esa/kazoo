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

--  This package covers the generation of code for all supported languages
--  There is no code that is specific to one particular language. The package
--  looks for a sub-directory with the name of the language and checks that all
--  skeleton-related template files are present. Then it fills the Template
--  mappings and generate the corresponding code.

package body TASTE.Backend.Skeletons is
   procedure Generate (Model : TASTE_Model) is
      All_CP_Files     : Tag;  --  List of Context Parameters ASN.1 files
      Template         : constant IV_As_Template :=
                                Interface_View_Template (Model.Interface_View);

      Prefix           : constant String := Model.Configuration.Binary_Path.all
                                            & "templates/";

      Prefix_Skeletons  : constant String := Prefix & "skeletons/";
      Prefix_Wrappers   : constant String := Prefix & "glue/language_wrappers";
      Prefix_Middleware : constant String :=
                                          Prefix & "glue/middleware_interface";

      use Ada.Strings.Unbounded;

      --  Return a Tag list of ASN.1 Modules for the headers
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

      function CP_To_ASN1 (Content : Translate_Set) return String is
         Tmplt_CP : constant String := Prefix_Skeletons
                                       & "context_parameters.tmplt";
      begin
         return Parse (Tmplt_CP, Content);
      end CP_To_ASN1;

      --  Generate a global Makefile (processing all functions)
      procedure Generate_Global_Makefile is
         package Languages_Set is new Ordered_Sets (Unbounded_String);
         use Languages_Set;
         Output_File      : File_Type;
         Languages        : Set;
         Unique_Languages : Tag;
         Functions_Tag    : Vector_Tag;
         Language_Tag     : Vector_Tag;
         Is_Type_Tag      : Vector_Tag;
         Content_Set      : Translate_Set;
         Tmplt            : constant String := Prefix_Skeletons
                                               & "makefile.tmplt";
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
                        & Assoc ("CP_Files",         All_CP_Files)
                        & Assoc ("Unique_Languages", Unique_Languages)
                        & Assoc ("ASN1_Files",       Get_ASN1_File_List)
                        & Assoc ("ASN1_Modules",     Get_Module_List);
         Put_Info ("Generating global Makefile");
         Create (File => Output_File,
                 Mode => Out_File,
                 Name => Model.Configuration.Output_Dir.all
                         & "/" & "Makefile");
         Put_Line (Output_File, Parse (Tmplt, Content_Set));
         Close (Output_File);
      end Generate_Global_Makefile;

      --  Render an set (Tag) of interfaces by applying a template
      function Process_Interfaces (Interfaces : Interface_Vectors.Vector;
                                   Path       : String) return Tag
      is
         Result : Tag;
         Tmplt_Sign  : constant String := Path & "interface.tmplt";
      begin
         for Each of Interfaces loop
            Result := Result & String'(Parse (Tmplt_Sign, Each.Header));
         end loop;
         return Result;
      end Process_Interfaces;

      --  Generate the ASN.1 files that represent Context Parameters for
      --  a function
      procedure Process_Context_Parameters
                               (F           : Taste_Terminal_Function;
                                Output_Lang : String)
      is
         Output_File : File_Type;
         CP_Tmpl     : constant Translate_Set := CP_Template (F => F);
         CP_Text     : constant String := CP_To_ASN1 (CP_Tmpl);
         CP_File     : constant String := "Context-"
                                         & To_Lower (To_String (F.Name))
                                         & ".asn";
      begin
         if not F.Context_Params.Is_Empty then
            Create_Path (Output_Lang);
            Put_Info ("Generating " & CP_File);
            Create (File => Output_File,
                    Mode => Out_File,
                    Name => Output_Lang & CP_File);
            Put_Line (Output_File, CP_Text);
            Close (Output_File);
            All_CP_Files :=
               All_CP_Files & ("../" & Output_Lang & CP_File);
         end if;
      exception
         when E : End_Error
         | Text_IO.Use_Error =>
            if Is_Open (Output_File) then
               Close (Output_File);
            end if;
            raise Skeleton_Error with "Generation of code for function "
                                      & To_String (F.Name) & " failed : "
                                      & Exception_Message (E);
      end Process_Context_Parameters;

      --  Write a header or body file for a function, a corresponding
      --  Makefile, and/or context parameters
      procedure Process_Template (F           : Taste_Terminal_Function;
                                  File_Name   : String := "";
                                  Make_File   : String := "";
                                  Path        : String;
                                  Output_Lang : String;
                                  Output_Sub  : String := "src/") is
         Output_File : File_Type;
         Make_Tmpl   : constant Translate_Set := Function_Makefile_Template
                                     (F       => F,
                                      Modules => Get_Module_List,
                                      Files   => Get_ASN1_File_List);

         Make_Path   : constant String := Path & "makefile.tmplt";
         Make_Text   : constant String :=
            (if Make_File /= "" and then Exists (Make_Path)
             then Parse (Make_Path, Make_Tmpl) else "");

         Func_Tmpl   : constant Func_As_Template :=
                                Template.Funcs.Element (To_String (F.Name));

         Func_Map    : constant Translate_Set :=
                         Func_Tmpl.Header
                         & Assoc ("Provided_Interfaces",
                                  Process_Interfaces
                                     (Func_Tmpl.Provided, Path))
                         & Assoc ("Required_Interfaces",
                                  Process_Interfaces
                                     (Func_Tmpl.Required, Path))
                         & Assoc ("ASN1_Modules", Get_Module_List)
                         & Assoc ("ASN1_Files", Get_ASN1_File_List);

         Content     : constant String :=
                                    Parse (Path & "function.tmplt", Func_Map);

         Output_Dir  : constant String := Output_Lang & Output_Sub;
      begin
         --  Create directory tree (output/function/language/src)
         Create_Path (Output_Dir);
         if File_Name /= "" then
            Put_Info ("Generating " & Output_Dir & File_Name);
            Create (File => Output_File,
                    Mode => Out_File,
                    Name => Output_Dir & File_Name);
            Put_Line (Output_File, Content);
            Close (Output_File);
         end if;
         if Make_File /= "" then
            Put_Info ("Generating " & Make_File & " for function "
                      & To_String (F.Name));
            Create (File => Output_File,
                    Mode => Out_File,
                    Name => Output_Lang & Make_File);
            Put_Line (Output_File, Make_Text);
            Close (Output_File);
         end if;
      exception
         when E : End_Error
         | Text_IO.Use_Error =>
            if Is_Open (Output_File) then
               Close (Output_File);
            end if;
            raise Skeleton_Error with "Generation of code for function "
                                      & To_String (F.Name) & " failed : "
                                      & Exception_Message (E);
      end Process_Template;

      --  Main loop generating skeletons for each function
      --  Prefix is where the templates are located
      --  Output_Base is the output folder defined in the command line
      --  Output_Sub is where the code shall be generated (e.g. "src")
      procedure Generate_From_Templates (Prefix      : String;
                                         Output_Base : String;
                                         Output_Sub  : String := "src/") is
      begin
         Put_Info ("=== Generate code with templates from " & Prefix & " ===");
         for Each of Model.Interface_View.Flat_Functions loop
            --  There can be multiple folders containing templates, iterate
            declare
               Language   : constant String := Language_Spelling (Each);
               ST         : Search_Type;
               Current    : Directory_Entry_Type;
               Filter     : constant Filter_Type := (Directory => True,
                                                     others    => False);
               --  File_Tmpl: to get the output filename from user template
               File_Tmpl  : constant Translate_Set :=
                  +Assoc  ("Name", Each.Name);
               --  Base output folder where code is generated
               --  e.g. output/ada/src/
               Output_Lang : constant String := Output_Base
                  & To_Lower (To_String (Each.Name))
                  & "/" & Language & "/";
               Output_Dir  : constant String := Output_Lang & Output_Sub;
            begin
               Start_Search (Search    => ST,
                             Pattern   => "",
                             Directory => Prefix,
                             Filter    => Filter);

               if not More_Entries (ST) then
                  Put_Error ("No folders with templates were found");
               end if;

               --  Iterate over the folders and process templates. Each folder
               --  shall contain a template named "trigger.tmplt" allowing
               --  the engine to decide if code should be generated or not
               --  based on user-defined critera (e.g. language)
               while More_Entries (ST) loop
                  Get_Next_Entry (ST, Current);
                  declare
                     --  Path is where the template files are located
                     Path      : constant String := Full_Name (Current);
                     --  Do_Func is true if there is a template for the
                     --  generation of a function template
                     Do_Func   : constant Boolean :=
                        Exists (Path & "/function-filename.tmplt");
                     --  Do_Func is true if there is a template for the
                     --  generation of a build script/Makefile template
                     Do_Make   : constant Boolean :=
                        Exists (Path & "/makefile-filename.tmplt");
                     --  File_Name is the output file to generate,
                     --  as parsed from the template file
                     File_Name : constant String :=
                        (if Do_Func
                         then
                            Strip_String (Parse
                               (Path & "/function-filename.tmplt", File_Tmpl))
                         else "");
                     --  User can define the name of the build script
                     --  to generate.. Typycally, for a function, "Makefile"
                     Make_Name : constant String :=
                        (if Do_Make
                         then
                            Strip_String (Parse
                               (Path & "/makefile-filename.tmplt", File_Tmpl))
                         else "");
                     --  Present_F is True if the function file already exists
                     Present_F : constant Boolean :=
                        (File_Name /= "" and Exists (Output_Dir & File_Name));
                     --  Present_M is True if the Makefile already exists
                     Present_M : constant Boolean :=
                        (Make_Name /= "" and Exists (Output_Dir & Make_Name));
                     --  Data needed to process trigger.tmplt
                     Trig_Tmpl  : constant Translate_Set :=
                                          +Assoc  ("Name", Each.Name)
                                          & Assoc ("Language",
                                                   Language_Spelling (Each))
                                          & Assoc ("Is_Type", Each.Is_Type)
                                          & Assoc ("Instance_Of",
                                           Each.Instance_Of.Value_Or (US ("")))
                                          & Assoc ("C_Middleware",
                                                 Model.Configuration.Use_POHIC)
                                          & Assoc ("Filename_Is_Present",
                                                   Present_F)
                                          & Assoc ("Makefile_Is_Present",
                                                   Present_M);
                     --  Trigger is set to True by the template
                     Trigger    : constant Boolean :=
                        (Exists (Path & "/trigger.tmplt")
                         and then Strip_String (Parse
                            (Path & "/trigger.tmplt", Trig_Tmpl)) = "TRUE");
                  begin
                     if Trigger then
                        --  Output code and Makefile from this template folder
                        Process_Template (F           => Each,
                                          File_Name   => File_Name,
                                          Make_File   => Make_Name,
                                          Path        => Path & "/",
                                          Output_Lang => Output_Lang,
                                          Output_Sub  => Output_Sub);
                     else
                        Put_Info ("Nothing to generate from templates in "
                                  & Path);
                     end if;
                  end;
               end loop;
               End_Search (ST);
               Process_Context_Parameters (F           => Each,
                                           Output_Lang => Output_Lang);
            end;
         end loop;
      end Generate_From_Templates;

   begin
      Generate_From_Templates (Prefix      => Prefix_Skeletons,
                               Output_Base =>
                                  Model.Configuration.Output_Dir.all & "/",
                               Output_Sub  => "src/");
      Generate_Global_Makefile;
      if Model.Configuration.Glue then
         Generate_From_Templates (Prefix     => Prefix_Wrappers,
                                  Output_Base =>
                                     Model.Configuration.Output_Dir.all & "/",
                                  Output_Sub => "wrappers/");
         Generate_From_Templates (Prefix     => Prefix_Middleware,
                                  Output_Base =>
                                     Model.Configuration.Output_Dir.all & "/",
                                  Output_Sub => "middleware_glue/");
      end if;
   end Generate;

   --  Functions that transform the AST into Templates:
   --  * Context Parameters
   --  * Makefile (per function)
   --  * A single interface
   --  * A single taste function
   --  * The complete interface view

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
