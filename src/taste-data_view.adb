--  *************************** taste aadl parser ***********************  --
--  (c) 2018 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

--  Interface View parser

with Locations,
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
       Ocarina.Analyzer,
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
      use type ASN1_Maps.Map;
      System            : Node_Id;
      Files             : ASN1_Maps.Map;
      Current_Type      : Node_Id;

      function Parse_Type (Data_Type : Node_Id) return ASN1_File is
         Asntype : constant Node_Id := Corresponding_Instance (Data_Type);
         Name    : constant String := Get_Name_String
                                         (Get_Type_Source_Name (Asntype));
      begin
         Put_Line ("Data type : " & AIN_Case (Data_Type));
         Put_Line (" |_" & Name);
         Put_Line (" |_ Module : " & Get_Name_String
                                          (Get_String_Property (Asntype,
                               Get_String_Name ("taste::ada_package_name"))));
         Put_Line (" |_ File : " & Get_Name_String
                                         (Get_Source_Text (Asntype)(1)));
         return ASN1_File'(Path => US (Name),
                           Modules => String_Vectors.Empty_Vector); --  TODO
      end Parse_Type;

      F   : Name_Id;
      Loc : Location;
   begin
      Ocarina.FE_AADL.Parser.Add_Pre_Prop_Sets := True;

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
            Type_File : constant ASN1_File := Parse_Type (Current_Type);
         begin
            Files.Insert (Key      => To_String (Type_File.Path),
                          New_Item => Type_File);
            Current_Type := AIN.Next_Node (Current_Type);
         end;
      end loop;

      return Data_AST : constant Taste_Data_View := (ASN1_Files => Files);
   end Parse_Data_View;

   procedure Debug_Dump (DV : Taste_Data_View; Output : File_Type) is
   begin
      for Each of DV.ASN1_Files loop
         Put_Line (Output, To_String (Each.Path));
         for Module of Each.Modules loop
            Put_Line (Output, "  |_Module : " & Module);
         end loop;
      end loop;
   end Debug_Dump;
end TASTE.Data_View;
