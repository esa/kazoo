--  *************************** taste aadl parser *************************  --
--  (c) 2008-2017 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

with Ada.Text_IO,
     Parser_Version,
     Ocarina.AADL_Values,
     Ocarina.Configuration,
     Ocarina.FE_AADL.Parser,
     Ocarina.Instances.Queries,
     GNAT.OS_Lib,
     Ada.Characters.Latin_1,
     GNAT.Command_Line;

package body Parser_Utils is

   use Ada.Text_IO,
       Ocarina.Instances.Queries,
       Ada.Characters.Latin_1,
       GNAT.OS_Lib,
       Ocarina.ME_AADL,
       GNAT.Command_Line;

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

      Put ("-l, --glue" & HT & HT & HT & HT);
      Put_Line ("Generate glue code");

      Put ("-w, --gw" & HT & HT & HT & HT);
      Put_Line ("Generate code skeletons");

      Put ("-o, --output <outputDir>" & HT & HT);
      Put_Line ("Root directory for the output files");

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

      Put_Line ("For example, this command will generate your application"
       & " skeletons:");
      New_Line;
      Put_Line ("taste-aadl-parser -i InterfaceView.aadl -d DataView.aadl"
       & " -o code --gw --keep-case");
      New_Line;

   end Usage;

   function Parse_Command_Line return Taste_Configuration is
      Config : Command_Line_Configuration;
      Result : Taste_Configuration;
   begin
      Define_Switch (Config, Output => Result.Interface_View'Access,
                     Switch   => "-i:", Long_Switch => "--interfaceview=",
                     Help     => "Mandatory interface view (AADL model)",
                     Argument => "InterfaceView.aadl");
      Define_Switch (Config, Output => Result.Deployment_View'Access,
                     Switch   => "-c:", Long_Switch => "--deploymentview=",
                     Help     => "Optional deployment view (AADL model)",
                     Argument => "DeploymentView.aadl");
      Define_Switch (Config, Output => Result.Data_View'Access,
                     Switch   => "-d:", Long_Switch => "--dataview=",
                     Help     => "Optional data view (AADL model)",
                     Argument => "DataView.aadl");
      Getopt (Config);
      loop
         declare
            S : constant String := Get_Argument;
         begin
            exit when S'Length = 0;
            Put_Line ("File argument : " & S);
         end;
      end loop;
      return Result;
   end Parse_Command_Line;

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

   ------------------------
   -- Get_Interface_Name --
   ------------------------

   function Get_Interface_Name (D : Node_Id) return Name_Id is
      Interface_Name : constant Name_id :=
         Get_String_Name ("taste::interfacename");
   begin
      return Get_String_Property (D, Interface_Name);
   end Get_Interface_Name;

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

   --  Initialization step: we look for ocarina on path to define
   --  OCARINA_PATH env. variable. This will indicate Ocarina librrary
   --  where to find AADL default property sets, and Ocarina specific
   --  packages and property sets.
   procedure Initialize_Ocarina is
      S : constant GNAT.OS_Lib.String_Access :=
        GNAT.OS_Lib.Locate_Exec_On_Path ("ocarina");
   begin
      if S = null then
         raise AADL_Parser_Error with "Ocarina is not in your PATH";
      end if;
      GNAT.OS_Lib.Setenv ("OCARINA_PATH", S.all (S'First .. S'Last - 12));
      Ocarina.Initialize;
      Ocarina.AADL_Version := Ocarina.AADL_V2;
      Ocarina.Configuration.Init_Modules;
      Ocarina.FE_AADL.Parser.Add_Pre_Prop_Sets := True;
   end Initialize_Ocarina;
end Parser_Utils;
