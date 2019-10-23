with Text_IO; use Text_IO;
with Ada.Characters.Handling,
     Ada.Containers.Ordered_Sets,
     Ada.Exceptions,
     Ada.Directories,
     TASTE.Parser_Utils;

use Ada.Characters.Handling,
    Ada.Containers,
    Ada.Exceptions,
    Ada.Directories,
    TASTE.Parser_Utils;

--  This package covers the generation of code for all supported languages
--  There is no code that is specific to one particular language. The package
--  looks for a sub-directory with the name of the language and checks that all
--  skeleton-related template files are present. Then it fills the Template
--  mappings and generate the corresponding code.

package body TASTE.Backend.Code_Generators is
   procedure Generate (Model : TASTE_Model) is
      All_CP_Files     : Tag;  --  List of Context Parameters ASN.1 files
      Template         : constant IV_As_Template :=
                                Interface_View_Template (Model.Interface_View);

      --  Path to the input templates files
      Prefix           : constant String :=
        Model.Configuration.Binary_Path.Element & "/templates/";

      Prefix_Skeletons  : constant String := Prefix & "skeletons/";
      Prefix_Wrappers   : constant String := Prefix & "glue/language_wrappers";

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

      --  Return a Tag list of ACN Files
      function Get_ACN_File_List return Tag is
         Result : Tag;
      begin
         for Each of Model.Data_View.ACN_Files loop
            Result := Result & Each;
         end loop;
         return Result;
      end Get_ACN_File_List;

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
            raise ACG_Error with "Missing makefile.tmplt";
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
                        & Assoc ("ACN_Files",        Get_ACN_File_List)
                        & Assoc ("ASN1_Modules",     Get_Module_List);
         Put_Debug ("Generating global Makefile");
         Create (File => Output_File,
                 Mode => Out_File,
                 Name => Model.Configuration.Output_Dir.Element & "/Makefile");
         Put_Line (Output_File, Parse (Tmplt, Content_Set));
         Close (Output_File);
      end Generate_Global_Makefile;

      --  Render a set (Tag) of interfaces by applying a template
      function Process_Interfaces (Interfaces : Template_Vectors.Vector;
                                   Path       : String) return Tag
      is
         Result : Tag;
         Tmplt_Sign  : constant String := Path & "interface.tmplt";
      begin
         for Each of Interfaces loop
            Result := Result & String'(Parse (Tmplt_Sign, Each));
         end loop;
         return Result;
      end Process_Interfaces;

      --  Generate the ASN.1 files translating Context Parameters
      procedure Process_Context_Parameters
                               (F           : Taste_Terminal_Function;
                                Output_Lang : String)
      is
         Output_File : File_Type;
         CP_Tmpl     : constant Translate_Set := CP_Template (F => F);
         CP_Text     : constant String :=
            (Parse (Prefix_Skeletons & "context_parameters.tmplt", CP_Tmpl));
         CP_File     : constant String :=
           "Context-" & To_Lower (To_String (F.Name)) & ".asn";
         CP_File_Dash : Unbounded_String;

      begin
         --  To keep backward compatibility, file name uses dash
         for C of CP_File loop
            CP_File_Dash := CP_File_Dash & (if C = '_' then '-' else C);
         end loop;

         if not F.Context_Params.Is_Empty then
            Create_Path (Output_Lang);
            Put_Debug ("Generating " & To_String (CP_File_Dash));
            Create (File => Output_File,
                    Mode => Out_File,
                    Name => Output_Lang & To_String (CP_File_Dash));
            Put_Line (Output_File, CP_Text);
            Close (Output_File);
            All_CP_Files :=
               All_CP_Files & ("../" & Output_Lang & To_String (CP_File_Dash));
         end if;
      exception
         when E : End_Error
         | Text_IO.Use_Error =>
            if Is_Open (Output_File) then
               Close (Output_File);
            end if;
            raise ACG_Error with "Generation of code for function "
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
            Put_Debug ("Generating " & Output_Dir & File_Name);
            Create (File => Output_File,
                    Mode => Out_File,
                    Name => Output_Dir & File_Name);
            Put_Line (Output_File, Content);
            Close (Output_File);
         end if;
         if Make_File /= "" then
            Put_Debug ("Generating " & Make_File & " for function "
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
            raise ACG_Error with "Generation of code for function "
                                 & To_String (F.Name) & " failed : "
                                 & Exception_Message (E);
      end Process_Template;

      --  Main loop generating output for each function
      --  Prefix is where the templates are located
      --  Output_Base is the output folder defined in the command line
      --  Output_Sub is where the code shall be generated (e.g. "src")
      procedure Generate_From_Templates (Prefix      : String;
                                         Output_Base : String;
                                         Output_Sub  : String := "src/") is
      begin
         Put_Debug ("== Generate code with templates from " & Prefix & " ==");
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
               --  e.g. output/Ada/src/
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

                     --  Do_Make is true if there is a template for the
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
                     --  to generate (typically, for a function, "Makefile")
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
                     --  Includes function attributes (name, zip file, etc)
                     --  and the command line configuration (Use_POHIC, etc.)
                     Trig_Tmpl  : constant Translate_Set :=
                       Join_Sets (Model.Configuration.To_Template,
                                  Template.Funcs.Element
                                    (To_String (Each.Name)).Header)
                       & Assoc ("Filename_Is_Present", Present_F)
                       & Assoc ("Makefile_Is_Present", Present_M);

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
                                  Model.Configuration.Output_Dir.Element & "/",
                               Output_Sub  => "src/");
      Generate_Global_Makefile;
      if Model.Configuration.Glue then
         Generate_From_Templates (Prefix     => Prefix_Wrappers,
                                  Output_Base =>
                                    Model.Configuration.Output_Dir.Element
                                       & "/",
                                  Output_Sub => "wrappers/");
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
      package Sort_Set is new Ordered_Sets (Unbounded_String);
      use Sort_Set;
      Sorts_Set    : Set;
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
      return Result : constant Translate_Set :=
        +Assoc ("Name",            F.Name)
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

   function Interface_View_Template (IV : Complete_Interface_View)
                                     return IV_As_Template is
      Result : IV_As_Template;
   begin
      for Each of IV.Flat_Functions loop
         Result.Funcs.Insert (Key      => To_String (Each.Name),
                              New_Item => Each.Function_To_Template);
      end loop;
      for C of IV.Connections loop
         Result.Callers  := Result.Callers  & C.Caller;
         Result.Callees  := Result.Callees  & C.Callee;
         Result.RI_Names := Result.RI_Names & C.RI_Name;
         Result.PI_Names := Result.PI_Names & C.PI_Name;
      end loop;
      return Result;
   end Interface_View_Template;
end TASTE.Backend.Code_Generators;
