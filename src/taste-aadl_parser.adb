--  ************************ TASTE AADL Parser **************************  --
--  Based on Ocarina ****************************************************  --
--  (c) 2018 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

with System.Assertions,
     GNAT.Command_Line,
     Ada.Exceptions,
     Ada.Text_IO,
     Errors,
     Locations,
     Ocarina.Namet,
     Ocarina.Configuration,
     Ocarina.Files,
     Ocarina.Parser,
     TASTE.Backend.Build_Script,
     TASTE.Backend.Skeletons;

use Ada.Text_IO,
    Ada.Exceptions,
    Locations,
    Ocarina.Namet,
    Ocarina;

package body TASTE.AADL_Parser is

   function Initialize return Taste_Configuration is
      File_Name      : Name_Id;
      File_Descr     : Location;
      Current_Config : Taste_Configuration;
   begin
      Banner;
      --  Parse arguments before initializing Ocarina, otherwise Ocarina eats
      --  some arguments (all file parameters).
      Parse_Command_Line (Current_Config);
      Initialize_Ocarina;

      AADL_Language := Get_String_Name ("aadl");

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
         --  Also parse the data view as a root component
         Dataview_root := Ocarina.Parser.Parse
                            (AADL_Language, Dataview_root, File_Descr);
      end if;
      return Current_Config;
   end Initialize;

   function Parse_Project return TASTE_Model is
      Result : TASTE_Model;
   begin
      Result.Configuration := Initialize;

      begin
         Result.Interface_View := Parse_Interface_View (Interface_Root);
      exception
         when System.Assertions.Assert_Failure =>
            raise AADL_Parser_Error with "Interface view parsing error";
      end;

      if Result.Configuration.Deployment_View.all'Length > 0 then
         AADL_Lib.Append (Result.Configuration.Interface_View.all);
         Result.Deployment_View := Parse_Deployment_View (Deployment_Root);
      end if;

      if Result.Configuration.Data_View.all'Length > 0 then
         begin
            Result.Data_View := Parse_Data_View (Dataview_root);
         exception
            when Constraint_Error =>
               raise Data_View_Error with "Update your data view!";
         end;
      end if;

      Ocarina.Configuration.Reset_Modules;
      Ocarina.Reset;

      return Result;
   exception
      when Error : AADL_Parser_Error
         | Interface_Error
         | Function_Error
         | No_RCM_Error
         | Deployment_View_Error
         | Data_View_Error
         | Device_Driver_Error =>
         Put (Red_Bold & "[ERROR] " & White_Bold);
         Put_Line (Exception_Message (Error) & No_Color);
         raise Quit_Taste;
      when GNAT.Command_Line.Exit_From_Command_Line =>
         New_Line;
         Put (Yellow_Bold & "[INFO] " & No_Color);
         Put ("For more information, visit " & Underline & White_Bold);
         Put_Line ("https://taste.tools" & No_Color);
         raise Quit_Taste;
      when GNAT.Command_Line.Invalid_Switch
         | GNAT.Command_Line.Invalid_Parameter
         | GNAT.Command_Line.Invalid_Section =>
         Put (Red_Bold & "[ERROR] " & White_Bold);
         Put_Line ("Invalid switch or parameter (try --help)" & No_Color);
         raise Quit_Taste;
      when E : others =>
         Errors.Display_Bug_Box (E);
         raise Quit_Taste;
   end Parse_Project;

   procedure Dump (Model : TASTE_Model) is
   begin
      Put_Line ("==== Dump of the Interface View ====");
      Model.Interface_View.Debug_Dump;
      if Model.Configuration.Deployment_View.all'Length > 0 then
         Put_Line ("==== Dump of the Deployment View ====");
         Model.Deployment_View.Debug_Dump;
      end if;
      Put_Line ("==== Dump of the Data View ====");
      Model.Data_View.Debug_Dump;
      Put_Line ("==== Dump of the Command Line ====");
      Model.Configuration.Debug_Dump;
   end Dump;

   procedure Generate_Build_Script (Model : TASTE_Model) is
   begin
      TASTE.Backend.Build_Script.Generate (Model);
   end Generate_Build_Script;

   procedure Generate_Skeletons (Model : TASTE_Model) is
   begin
      TASTE.Backend.Skeletons.Generate (Model);
   end Generate_Skeletons;

end TASTE.AADL_Parser;
