--  ************************ TASTE AADL Parser **************************  --
--  Based on Ocarina ****************************************************  --
--  (c) 2017 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

with GNAT.Command_Line,
     Ada.Exceptions,
     Ada.Text_IO,
     GNAT.OS_Lib,
     Errors,
     Locations,
     Ocarina.Namet,
     Ocarina.Types,
     Ocarina.Analyzer,
     Ocarina.Configuration,
     Ocarina.Files,
     Ocarina.Options,
     Ocarina.Instances,
     Ocarina.ME_AADL.AADL_Instances.Nodes,
     Ocarina.Parser,
     Parser_Utils,
     Interface_View,
     Deployment_View;

use Ada.Text_IO,
    Ada.Exceptions,
    Locations,
    Ocarina.Namet,
    Ocarina.Types,
    Ocarina,
    Ocarina.Analyzer,
    Ocarina.Instances,
    Ocarina.ME_AADL,
    Ocarina.ME_AADL.AADL_Instances.Nodes,
    Parser_Utils,
    Interface_View,
    Deployment_View,
    GNAT.OS_Lib;

procedure AADL_Parser is
   AADL_Language : Name_Id;

   Interface_Root    : Node_Id := No_Node;
   Deployment_root   : Node_Id := No_Node;
   Dataview_root     : Node_ID := No_Node;
   Success           : Boolean;
   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
      File_Name  : Name_Id;
      File_Descr : Location;
   begin
      AADL_Language := Get_String_Name ("aadl");

      Dump_Configuration (Current_Config);

      if Current_Config.Interface_View.all'Length = 0 then
         Current_Config.Interface_View := Default_Interface_View'Access;
      end if;

      Set_Str_To_Name_Buffer (Current_Config.Interface_View.all);

      File_Name := Ocarina.Files.Search_File (Name_Find);
      if File_Name = No_Name then
         raise AADL_Parser_Error
           with "File not found : " & Current_Config.Interface_View.all;
      end if;

      File_Descr := Ocarina.Files.Load_File (File_Name);

      Interface_Root := Ocarina.Parser.Parse
        (AADL_Language, Interface_Root, File_Descr);

      if Current_Config.Glue then
         if Current_Config.Deployment_View.all'Length = 0 then
            Current_Config.Deployment_View := Default_Deployment_View'Access;
         end if;

         Set_Str_To_Name_Buffer (Current_Config.Deployment_View.all);

         File_Name := Ocarina.Files.Search_File (Name_Find);
         if File_Name = No_Name then
            raise AADL_Parser_Error
              with "File not found : " & Current_Config.Deployment_View.all;
         end if;

         File_Descr := Ocarina.Files.Load_File (File_Name);
         Deployment_Root := Ocarina.Parser.Parse
           (AADL_Language, Deployment_Root, File_Descr);

         if Deployment_Root = No_Node then
            raise AADL_Parser_Error with "Deployment View is incorrect";
         end if;
      end if;

      for Each of Current_Config.Other_Files loop
         Set_Str_To_Name_Buffer (Each);
         File_Name := Ocarina.Files.Search_File (Name_Find);
         if File_Name = No_Name then
            raise AADL_Parser_Error with "File not found: " & Each;
         end if;
         File_Descr := Ocarina.Files.Load_File (File_Name);

         --  Add other files to the Interface and (if any) deployment roots
         Interface_Root := Ocarina.Parser.Parse
           (AADL_Language, Interface_Root, File_Descr);
         if Deployment_Root /= No_Node then
            Deployment_Root := Ocarina.Parser.Parse
              (AADL_Language, Deployment_Root, File_Descr);
         end if;
      end loop;

      --  Missing data view is actually not an error.
      --  Systems can live with parameterless messages
      if Current_Config.Data_View.all'Length > 0 then
         Set_Str_To_Name_Buffer (Current_Config.Data_View.all);
         File_Name := Ocarina.Files.Search_File (Name_Find);
         if File_Name = No_Name then
            raise AADL_Parser_Error with "Cannot find the Data View file";
         end if;
      else
         --  Try with default name
         Set_Str_To_Name_Buffer (Default_Data_View);
         File_Name := Ocarina.Files.Search_File (Name_Find);
         if File_Name /= No_Name then
            Current_Config.Data_View := Default_Data_View'Access;
         end if;
      end if;

      if File_Name /= No_Name then
         File_Descr := Ocarina.Files.Load_File (File_Name);

         --  Add the Data View to the Interface View root
         Interface_Root := Ocarina.Parser.Parse
           (AADL_Language, Interface_Root, File_Descr);

         --  Add the Data View to the Deployment View root, if any
         if Deployment_Root /= No_Node then
            Deployment_Root := Ocarina.Parser.Parse
               (AADL_Language, Deployment_Root, File_Descr);
         end if;
         Dataview_root := Ocarina.Parser.Parse
                            (AADL_Language, Dataview_root, File_Descr);
      end if;

      if No (Interface_Root) then
         raise AADL_Parser_Error with "Internal error - please report.";
      end if;

      --  Analyze the tree

      Success := Ocarina.Analyzer.Analyze (AADL_Language, Interface_Root);
      if not Success then
         raise AADL_Parser_Error with "Could not analyse model";
      end if;
   end Initialize;

   IV_Root : Node_Id;
   IV_AST : Complete_Interface_View;
   DV_AST : Complete_Deployment_View;

begin
   Banner;
   --  Parse arguments before initializing Ocarina, otherwise Ocarina eats
   --  some arguments (all file parameters).
   Parse_Command_Line (Current_Config);
   Initialize_Ocarina;

   Initialize;

   --  First, we analyze the interface view.

   Ocarina.Options.Root_System_Name :=
          Get_String_Name ("interfaceview.others");

   IV_Root := Root_System (Instantiate_Model (Root => Interface_Root));
   IV_AST := Parse_Interface_View (IV_Root);

   IV_AST.Debug_Dump;

   --  Now, we are done with the interface view. We now analyze the
   --  deployment view.

   if Current_Config.Deployment_View.all'Length > 0 then
      AADL_Lib.Append (Current_Config.Interface_View.all);
      DV_AST := Parse_Deployment_View (Deployment_Root);
      DV_AST.Debug_Dump;
   end if;

   Ocarina.Configuration.Reset_Modules;
   Ocarina.Reset;

exception
   when Error : AADL_Parser_Error
      | Interface_Error
      | Function_Error
      | No_RCM_Error
      | Deployment_View_Error
      | Device_Driver_Error =>
      Put (Red_Bold & "[ERROR] " & White_Bold);
      Put_Line (Exception_Message (Error) & No_Color);
      OS_Exit (1);
   when GNAT.Command_Line.Exit_From_Command_Line =>
      New_Line;
      Put (Yellow_Bold & "[INFO] " & No_Color);
      Put ("For more information, visit " & Underline & White_Bold);
      Put_Line ("https://taste.tools" & No_Color);
   when GNAT.Command_Line.Invalid_Switch
         | GNAT.Command_Line.Invalid_Parameter
         | GNAT.Command_Line.Invalid_Section =>
         Put (Red_Bold & "[ERROR] " & White_Bold);
      Put_Line ("Invalid switch or parameter (try --help)" & No_Color);
      OS_Exit (1);
   when E : others =>
      Errors.Display_Bug_Box (E);
end AADL_Parser;
