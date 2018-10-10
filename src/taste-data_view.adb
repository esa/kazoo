--  *************************** taste aadl parser ***********************  --
--  (c) 2018 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

--  Interface View parser

with Ada.Directories,
     Locations,
     Ocarina.Instances.Queries,
     Ocarina.Analyzer,
     Ocarina.Backends.Properties,
     Ocarina.Options,
     Ocarina.Files,
     Ocarina.FE_AADL.Parser,
     Ocarina.Parser,
     Ocarina.Instances,
     Ocarina.ME_AADL.AADL_Instances.Nodes,
     Ocarina.Namet,
     Ocarina.ME_AADL.AADL_Instances.Entities;

package body TASTE.Data_View is

   use Locations,
       Ocarina.Instances.Queries,
       Ocarina.Namet,
       --  Ocarina.Analyzer,
       Ocarina.Backends.Properties,
       Ocarina.Options,
       Ocarina.Instances,
       Ocarina.ME_AADL.AADL_Instances.Nodes,
       Ocarina.ME_AADL.AADL_Instances.Entities,
       Ocarina.ME_AADL;

   ----------------------------
   --  AST Builder Functions --
   ----------------------------

   function Parse_Data_View (Dataview_Root : Node_Id) return Taste_Data_View
   is
      DV_Root : Node_Id := Dataview_Root;
      use ASN1_File_Maps;
      System            : Node_Id;
      Files             : ASN1_File_Maps.Map;
      Current_Type      : Node_Id;
      F                 : Name_Id;
      Loc               : Location;
   begin
      Ocarina.FE_AADL.Parser.Add_Pre_Prop_Sets := False;

      --  Parse all AADL files possibly needed to instantiate the model
      for Each of Data_View_AADL_Lib loop
         Set_Str_To_Name_Buffer (Each);
         F := Ocarina.Files.Search_File (Name_Find);
         Loc := Ocarina.Files.Load_File (F);
         DV_Root := Ocarina.Parser.Parse (Get_String_Name ("aadl"),
                                          DV_Root, Loc);
      end loop;

      if not Ocarina.Analyzer.Analyze (AADL_Language, DV_Root) then
         raise Data_View_Error with "Could not analyse Data View";
      end if;

      Ocarina.Options.Root_System_Name :=
                                    Get_String_Name ("taste_dataview.others");

      System := Root_System (Instantiate_Model (Root => DV_Root));

      if No (System) then
         raise Data_View_Error with "Could not instantiate Data View";
      end if;

      Current_Type := AIN.First_Node (AIN.Subcomponents (System));
      while Present (Current_Type) loop
         if Get_Category_Of_Component (Current_Type) /= CC_Data then
            raise Data_View_Error with "Component is not a data type!";
         end if;
         declare
            Asntype  : constant Node_Id :=
              Corresponding_Instance (Current_Type);
            Sort     : constant String  := Get_Name_String
                             (Get_Type_Source_Name (Asntype));
            Module   : constant String  := Get_Name_String
              (Get_String_Property (Asntype,
               Get_String_Name ("taste::ada_package_name")));
            Filename : constant String  := Get_Name_String
              (Get_Source_Text (Asntype) (1));
            File_Ref : constant ASN1_File_Maps.Cursor := Files.Find (Filename);
         begin
            if File_Ref = ASN1_File_Maps.No_Element then
               declare
                  New_File   : ASN1_File;
                  New_Module : ASN1_Module;
               begin
                  New_Module.Name  := US (Module);
                  New_Module.Types := (Empty_Vector & Sort);
                  New_File.Path    := US (Filename);
                  New_File.Modules.Insert (Module, New_Module);
                  Files.Insert            (Filename, New_File);
               end;
            else
               declare
                  Curr_File   : ASN1_File := Files.Element (Filename);
                  Curr_Module : ASN1_Module;
               begin
                  if Curr_File.Modules.Contains (Module) then
                     Curr_Module := Curr_File.Modules.Element (Module);
                     Curr_Module.Types.Append (Sort);
                     Curr_File.Modules.Replace (Module, Curr_Module);
                  else
                     Curr_Module.Name := US (Module);
                     Curr_Module.Types := (Empty_Vector & Sort);
                     Curr_File.Modules.Insert (Module, Curr_Module);
                  end if;
                  Files.Replace (Filename, Curr_File);
               end;
            end if;
         end;
         Current_Type := AIN.Next_Node (Current_Type);
      end loop;
      return Data_AST : constant Taste_Data_View := (ASN1_Files => Files);
   end Parse_Data_View;

   --  Function checking the actual file presence of the ASN.1 models that
   --  are referenced in the input file DataView.aadl. Raise an exception
   --  if any file is missing.
   procedure Check_Files (DV : Taste_Data_View) is
      Success : Boolean := True;
   begin
      for Each of DV.ASN1_Files loop
         if not Ada.Directories.Exists (To_String (Each.Path)) then
            Put_Error ("File not found: " & To_String (Each.Path));
            Success := False;
         end if;
      end loop;
      if not Success then
         raise Data_View_Error with
           "ASN.1 files missing (wrong path in DataView.aadl). "
           & "Run taste-update-data-view [list of ASN.1 files]";
      end if;
   end Check_Files;

   procedure Debug_Dump (DV : Taste_Data_View; Output : File_Type) is
   begin
      for Each of DV.ASN1_Files loop
         Put_Line (Output, "ASN.1 File : " & To_String (Each.Path));
         for Module of Each.Modules loop
            Put_Line (Output, "  |_Module : " &  To_String (Module.Name));
            for Sort of Module.Types loop
               Put_Line (Output, "    |_Type : " & Sort);
            end loop;
         end loop;
      end loop;
   end Debug_Dump;

   procedure Export_ASN1_Files (DV : Taste_Data_View; Output_Path : String) is
   begin
      for Each of DV.ASN1_Files loop
         Ada.Directories.Copy_File
                    (Source_Name => To_String (Each.Path),
                     Target_Name => Output_Path
                        & Ada.Directories.Simple_Name (To_String (Each.path)));
      end loop;
   end Export_ASN1_Files;
end TASTE.Data_View;
