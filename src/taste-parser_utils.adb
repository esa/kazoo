--  *************************** taste aadl parser *************************  --
--  (c) 2008-2017 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

with Ada.Text_IO,
     GNAT.OS_Lib,
     GNAT.Command_Line,
     Templates_Parser,
     Templates_Parser.Utils,
     Ocarina.AADL_Values,
     Ocarina.Configuration,
     Ocarina.FE_AADL.Parser,
     Ocarina.Instances.Queries,
     TASTE.Parser_Version,
     TASTE.Templates;

package body TASTE.Parser_Utils is

   use Ada.Text_IO,
       GNAT.OS_Lib,
       GNAT.Command_Line,
       Templates_Parser,
       Templates_Parser.Utils,
       Ocarina.Instances.Queries,
       Ocarina.ME_AADL,
       TASTE.Templates;

   procedure Banner is
      The_Banner : constant String :=
        Yellow_Bold & "TASTE AADL Parser" & No_Color & " (Version "
        & TASTE.Parser_Version.Parser_Release & ")"
        & ASCII.LF & ASCII.CR & White_Bold
        & "Copyright (C) European Space Agency"
        & ASCII.LF & ASCII.CR & No_Color
        & "Based on " & TASTE.Parser_Version.Ocarina_Version;
   begin
      Put_Line (The_Banner);
      New_Line;
   end Banner;

   procedure Parse_Command_Line (Result : out Taste_Configuration) is
      Config : Command_Line_Configuration;
   begin
      Result.Binary_Path := new String'(Get_Program_Directory);
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
      Define_Switch (Config, Output => Result.Output_Dir'Access,
                     Switch   => "-o:", Long_Switch => "--output=",
                     Help     => "Output directory (to be created if absent)",
                     Argument => "Folder");
      Define_Switch (Config, Output => Result.Skeletons'Access,
                     Switch   => "-w", Long_Switch => "--gw",
                     Help     => "Generate models and code skeletons");
      Define_Switch (Config, Output => Result.Glue'Access,
                     Switch   => "-l", Long_Switch => "--glue",
                     Help     => "Generate glue code");
      Define_Switch (Config, Output => Result.Use_POHIC'Access,
                     Switch   => "-p", Long_Switch => "--polyorb-hi-c",
                     Help     => "Use PolyORB-HI-C runtime in place of Ada");
      Define_Switch (Config, Output => Result.Timer_Resolution'Access,
                     Switch   => "-x:", Long_Switch => "--timer=",
                     Initial  => 100,
                     Help     => "Specify timer resolution (default 100 ms)");
      Define_Switch (Config, Output => Result.Debug_Flag'Access,
                     Switch   => "-g", Long_Switch => "--debug",
                     Help     => "Set debug mode");
      Define_Switch (Config, Output => Result.Version'Access,
                     Switch   => "-v", Long_Switch => "--version",
                     Help     => "Display tool version");
      Getopt (Config);

      loop
         declare
            S : constant String := Get_Argument;
         begin
            exit when S'Length = 0;
            Result.Other_Files.Append (S);
         end;
      end loop;

      if Result.Version then
         raise Exit_From_Command_Line;
      end if;
   end Parse_Command_Line;

   procedure Debug_Dump (Config : Taste_Configuration) is
      Vec : Tag;
   begin
      Put_Line ("Command line (raw dump):");
      Put_Line ("  |_ Interface View  : " & Config.Interface_View.all);
      Put_Line ("  |_ Deployment View : " & Config.Deployment_View.all);
      Put_Line ("  |_ Data View       : " & Config.Data_View.all);
      Put_Line ("  |_ Output Dir      : " & Config.Output_Dir.all);
      Put_Line ("  |_ Use POHIC       : " & Config.Use_POHIC'Img);
      Put_Line ("  |_ Glue            : " & Config.Use_POHIC'Img);
      Put_Line ("  |_ Skeletons       : " & Config.Skeletons'Img);
      Put_Line ("  |_ Timer Res       : " & Config.Timer_Resolution'Img);
      Put_Line ("  |_ Version         : " & Config.Version'Img);
      Put_Line ("  |_ Debug           : " & Config.Debug_Flag'Img);
      for Each of Config.Other_Files loop
         Put_Line ("  |_ Other file      : " & Each);
      end loop;

      Put_Line ("Dump generated from a template file:");
      New_Set;
      Tmpl_Map ("Interface_View",  Config.Interface_View.all);
      Tmpl_Map ("Deployment_View", Config.Deployment_View.all);
      Tmpl_Map ("Data_View", Config.Data_View.all);
      Tmpl_Map ("Output_Dir", Config.Output_Dir.all);
      for Each of Config.Other_Files loop
         Vec := Vec & Each;
      end loop;
      Tmpl_Map ("Other_Files",      Vec);
      Tmpl_Map ("Skeletons",        Config.Skeletons);
      Tmpl_Map ("Glue",             Config.Glue);
      Tmpl_Map ("Use_POHIC",        Config.Use_POHIC);
      Tmpl_Map ("Debug_Flag",       Config.Debug_Flag);
      Tmpl_Map ("Version",          Config.Version);
      Tmpl_Map ("Timer_Resolution", Config.Timer_Resolution);
      Put_Line (Generate (Config.Binary_Path.all
                          & "templates/configuration.tmplt"));
   end Debug_Dump;

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
end TASTE.Parser_Utils;
