--  *************************** taste aadl parser *************************  --
--  (c) 2008-2017 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

with Ada.Text_IO,
     Parser_Version,
     Ocarina.AADL_Values,
     Ocarina.Instances.Queries,
     Ada.Characters.Latin_1;

package body Parser_Utils is

   use Ada.Text_IO,
       Ocarina.Instances.Queries,
       Ada.Characters.Latin_1,
       Ocarina.ME_AADL;

   ------------
   -- Banner --
   ------------

   procedure Banner is
      The_Banner : constant String :=
        Yellow_Bold & "TASTE AADL Parser" & No_Color & " (Version "
        & Parser_Version.Parser_Release & ") "
        & ASCII.LF & ASCII.CR & No_Color
        & "Contact: " & Underscore
        & "Maxime.Perrotin@esa.int" & No_Color & " or " & Underscore
        & "Thanassis.Tsiodras@esa.int"
        & ASCII.LF & ASCII.CR & No_Color
        & "Based on " & Parser_Version.Ocarina_Version;
   begin
      Put_Line (The_Banner);
   end Banner;

   -----------
   -- Usage --
   -----------

   procedure Usage is
   begin
      Put_Line
        ("Usage: taste-aadl-parser <options> otherfiles");
      Put_Line
        ("Where <options> are:");
      New_Line;
      Put ("-l, --glue" & HT & HT & HT & HT);
      Put_Line ("Generate glue code");
      Put ("-w, --gw" & HT & HT & HT & HT);
      Put_Line ("Generate code skeletons");
      Put ("-j, --keep-case" & HT & HT & HT & HT);
      Put_Line ("Respect the case for interface names");
      Put ("-o, --output <outputDir>" & HT & HT);
      Put_Line ("Root directory for the output files");
      Put ("-i, --interfaceview <i_view.aadl>" & HT);
      Put_Line ("The interface view in AADL");
      Put ("-c, --deploymentview <d_view.aadl>" & HT);
      Put_Line ("The deployment view in AADL");
      Put ("-d, --dataview <dataview.aadl>" & HT & HT);
      Put_Line ("The data view in AADL");
      Put ("-t, --test" & HT & HT & HT & HT);
      Put_Line ("Dump model information");
      Put ("-g, --debug" & HT & HT & HT & HT);
      Put_Line ("Generate runtime debug output");
      Put ("-x, --timer <timer-resolution in ms>" & HT);
      Put_Line ("Set the timer resolution (default 100 ms)");
      Put ("-v, --version" & HT & HT & HT & HT);
      Put_Line ("Display taste-aadl-parser version number");
      Put ("-p, --polyorb-hi-c" & HT & HT & HT);
      Put_Line ("Interface glue code with PolyORB-HI-C");
      Put ("otherfiles" & HT & HT & HT & HT);
      Put_Line ("Any other aadl file you want to parse");
      New_Line;
      New_Line;
      Put_Line ("For example, this command will generate your application"
       & " skeletons:");
      New_Line;
      Put_Line ("taste-aadl-parser -i InterfaceView.aadl -d DataView.aadl"
       & " -o code --gw --keep-case");
      New_Line;

   end Usage;

   -------------------
   -- Exit_On_Error --
   -------------------

   procedure Exit_On_Error (Error : Boolean; Reason : String) is
   begin
      if Error then
         raise AADL_Parser_Error with Reason;
      end if;
   end Exit_On_Error;

   -----------------------
   -- Get_APLC_Binding --
   -----------------------

   function Get_APLC_Binding (E : Node_Id) return List_Id is
      APLC_Binding : constant Name_Id :=
          Get_String_Name ("taste::aplc_binding");
   begin
      if Is_Defined_Property (E, APLC_Binding) then
         return Get_List_Property (E, APLC_Binding);
      else
         return No_List;
      end if;
   end Get_APLC_Binding;

   --------------------------------------------
   -- Get all properties as a Map Key/String --
   -- Input parameter is an AADL instance    --
   --------------------------------------------
   function Get_Properties_Map (D : Node_Id) return Property_Maps.Map is
      properties : constant List_Id  := AIN.Properties (D);
      result     : Property_Maps.Map := Property_Maps.Empty_Map;
      property   : Node_Id           := AIN.First_Node (properties);
      prop_value : Node_Id;
      single_val : Node_Id;
   begin
      while Present (property) loop
         prop_value := AIN.Property_Association_Value (property);
         if Present (ATN.Single_Value (prop_value)) then
            --  Only support single-value properties for now
            single_val := ATN.Single_Value (prop_value);
            result.Insert (Key => AIN_Case (property),
                           New_Item => (Name  => US (AIN_Case (property)),
                                        Value =>
              US (case ATN.Kind (single_val) is
                 when ATN.K_Signed_AADLNumber =>
                   Ocarina.AADL_Values.Image
                      (ATN.Value (ATN.Number_Value (single_val))) &
                      (if Present (ATN.Unit_Identifier (single_val)) then " " &
                      Get_Name_String
                          (ATN.Display_Name (ATN.Unit_Identifier (single_val)))
                      else ""),
                 when ATN.K_Literal =>
                    Ocarina.AADL_Values.Image (ATN.Value (single_val),
                                               Quoted => False),
                 when ATN.K_Reference_Term =>
                    Get_Name_String
                       (ATN.Display_Name (ATN.First_Node --  XXX must iterate
                          (ATN.List_Items (ATN.Reference_Term (single_val))))),
                 when ATN.K_Enumeration_Term =>
                    Get_Name_String
                       (ATN.Display_Name (ATN.Identifier (single_val))),
                 when ATN.K_Number_Range_Term =>
                    "RANGE NOT SUPPORTED!",
                 when others => "ERROR! Unsupported kind: "
                                & ATN.Kind (single_val)'Img)));
         end if;
         property := AIN.Next_Node (property);
      end loop;
      return result;
   end Get_Properties_Map;

end Parser_Utils;
