--  ************************ TASTE AADL Parser **************************  --
--  Based on Ocarina ****************************************************  --
--  (c) 2017 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

with Ada.Command_Line,
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
     Ocarina.FE_AADL.Parser,
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
--   OutDir            : Natural := 0;
--   Stack_Val         : Natural := 0;
--   Timer_Resolution  : Natural := 0;
   Interface_View    : Natural := 0;
   Depl_View_Pos     : Natural := 0;
   Data_View         : Natural := 0;
   Generate_glue     : Boolean := false;
   AADL_Version      : AADL_Version_Type := Ocarina.AADL_V2;

   procedure Parse_Command_Line;
   --  procedure Process_DataView (My_Root : Node_Id);

   ----------------------------
   -- Process_Interface_View --
   ----------------------------

         --  Set the output directory
--        if OutDir > 0 then
--           C_Set_OutDir (Ada.Command_Line.Argument (Outdir),
--                         Ada.Command_Line.Argument (Outdir)'Length);
--        end if;
--
--        --  Set the stack value
--        if Stack_Val > 0 then
--           C_Set_Stack (Ada.Command_Line.Argument (stack_val),
--                        Ada.Command_Line.Argument (stack_val)'Length);
--        end if;
--
--        --  Set the timer resolution value
--        if Timer_Resolution > 0 then
--           C_Set_Timer_Resolution
--             (Ada.Command_Line.Argument (Timer_Resolution),
--              Ada.Command_Line.Argument (Timer_Resolution)'Length);
--        end if;

         --  Current_function is read from the list of system subcomponents

   -----------------------------------
   -- Browse_Deployment_View_System --
   -----------------------------------

--   procedure Browse_Deployment_View_System
--       (My_System : Node_Id; NodeName : String) is
--      Processes         : Node_Id;
--      Processes2        : Node_Id;
--      Tmp_CI            : Node_Id;
--      Tmp_CI2           : Node_Id;
--      Ref               : Node_Id;
--      CPU               : Node_Id;
--      CPU_Name          : Name_Id := No_Name;
--      Pkg_Name          : Name_Id := No_Name;
--      CPU_Classifier    : Name_Id := No_Name;
--      CPU_Platform      : Supported_Execution_Platform := Platform_None;

   ------------------------
   -- Parse_Command_Line --
   ------------------------

   procedure Parse_Command_Line is
      FN                : Name_Id;
      B                 : Location;
      Previous_OutDir   : Boolean := False;
      Previous_IFview   : Boolean := False;
      Previous_CView    : Boolean := False;
      Previous_DataView : Boolean := False;
      Previous_TimerRes : Boolean := False;
   begin
      for J in 1 .. Ada.Command_Line.Argument_Count loop
         --  Parse the file corresponding to the Jth argument of the
         --  command line and enrich the global AADL tree.

         if Previous_IfView then
            Interface_View := J;
            Previous_Ifview := false;

         elsif Previous_Cview then
            Depl_View_Pos := J;
            Previous_Cview := false;

         elsif Previous_DataView then
            Data_View := J;
            Previous_DataView := false;

         elsif Previous_Outdir then
            --  OutDir := J;
            Previous_OutDir := false;

         elsif Previous_TimerRes then
            --  Timer_Resolution := J;
            Previous_TimerRes := false;

         elsif Ada.Command_Line.Argument (J) = "--polyorb-hi-c"
           or else Ada.Command_Line.Argument (J) = "-p"
           or else Ada.Command_Line.Argument (J) = "-polyorb-hi-c"
         then
            null;

         elsif Ada.Command_Line.Argument (J) = "--glue"
           or else Ada.Command_Line.Argument (J) = "-glue"
           or else Ada.Command_Line.Argument (J) = "-l"
         then
            generate_glue := true;

         elsif Ada.Command_Line.Argument (J) = "--smp2"
           or else Ada.Command_Line.Argument (J) = "-m"
         then
            null;

         elsif Ada.Command_Line.Argument (J) = "--gw"
           or else Ada.Command_Line.Argument (J) = "-gw"
           or else Ada.Command_Line.Argument (J) = "-w"
         then
            null;

         --  The "test" flag activates a function in the parser,
         --  used for debugging purposes (e.g. dump of the model after
         --  all preprocessings). Users need not use it.
         elsif Ada.Command_Line.Argument (J) = "--test"
           or else Ada.Command_Line.Argument (J) = "-test"
           or else Ada.Command_Line.Argument (J) = "-t"
         then
            null;

         elsif Ada.Command_Line.Argument (J) = "--aadlv2"
           or else Ada.Command_Line.Argument (J) = "-aadlv2"
           or else Ada.Command_Line.Argument (J) = "-a"
         then
            AADL_Version := Ocarina.AADL_V2;

         elsif Ada.Command_Line.Argument (J) = "--future" then
            null;

         elsif Ada.Command_Line.Argument (J) = "--output"
           or else Ada.Command_Line.Argument (J) = "-o"
         then
            Previous_OutDir := True;

         elsif Ada.Command_Line.Argument (J) = "--interfaceview"
           or else Ada.Command_Line.Argument (J) = "-i"
         then
            Previous_Ifview := True;

         elsif Ada.Command_Line.Argument (J) = "--timer"
           or else Ada.Command_Line.Argument (J) = "-timer"
           or else Ada.Command_Line.Argument (J) = "-x"
         then
            Previous_TimerRes := True;

         elsif Ada.Command_Line.Argument (J) = "--deploymentview"
           or else Ada.Command_Line.Argument (J) = "-c"
         then
            Previous_Cview := True;

         elsif Ada.Command_Line.Argument (J) = "--version"
           or else Ada.Command_Line.Argument (J) = "-v"
         then
            OS_Exit (0);

         elsif Ada.Command_Line.Argument (J) = "--dataview"
           or else Ada.Command_Line.Argument (J) = "-d"
         then
            Previous_DataView := True;

         elsif Ada.Command_Line.Argument (J) = "--debug"
           or else Ada.Command_Line.Argument (J) = "-g"
         then
            null;

         elsif Ada.Command_Line.Argument (J) = "--help"
           or else Ada.Command_Line.Argument (J) = "-h"
         then
            Usage;
            OS_Exit (0);

         else
            Set_Str_To_Name_Buffer (Ada.Command_Line.Argument (J));
            FN := Ocarina.Files.Search_File (Name_Find);
            if FN = No_Name then
               raise AADL_Parser_Error with "File not found: "
                 & Ada.Command_Line.Argument (J);
            end if;

            B := Ocarina.Files.Load_File (FN);
            Interface_Root := Ocarina.Parser.Parse
              (AADL_Language, Interface_Root, B);

            --  the "else" makes the parser parse any additional aadl files
            --  (in complement to the interface/deployment/data views)
            --  they must therefore be part of Root AND Deployment_Root trees
            Set_Str_To_Name_Buffer (Ada.Command_Line.Argument (J));
            FN := Ocarina.Files.Search_File (Name_Find);
            B := Ocarina.Files.Load_File (FN);
            Deployment_Root := Ocarina.Parser.Parse
              (AADL_Language, Deployment_Root, B);
         end if;
      end loop;
   end Parse_Command_Line;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
      FN : Name_Id;
      B  : Location;
   begin
      --  Initialization step: we look for ocarina on path to define
      --  OCARINA_PATH env. variable. This will indicate Ocarina librrary
      --  where to find AADL default property sets, and Ocarina specific
      --  packages and property sets.

      declare
            S : constant GNAT.OS_Lib.String_Access :=
               GNAT.OS_Lib.Locate_Exec_On_Path ("ocarina");
      begin
         if S = null then
            raise AADL_Parser_Error with "Ocarina is not in your PATH";
         end if;

         GNAT.OS_Lib.Setenv ("OCARINA_PATH", S.all (S'First .. S'Last - 12));
      end;

      --  Display the command line syntax

      if Ada.Command_Line.Argument_Count = 0 then
         Usage;
         raise AADL_Parser_Error with "Missing command line arguments";
      end if;

      Ocarina.Initialize;
      Ocarina.AADL_Version := AADL_Version;

      Ocarina.Configuration.Init_Modules;

      Ocarina.FE_AADL.Parser.Add_Pre_Prop_Sets := True;
      AADL_Language := Get_String_Name ("aadl");

      Parse_Command_Line;
      if Interface_View = 0 then
         --  Try default filename
         Set_Str_To_Name_Buffer ("InterfaceView.aadl");
      else
         Set_Str_To_Name_Buffer (Ada.Command_Line.Argument (Interface_View));
      end if;

      FN := Ocarina.Files.Search_File (Name_Find);
      if FN = No_Name then
         raise AADL_Parser_Error with "Interface View missing";
      end if;

      B := Ocarina.Files.Load_File (FN);

      Interface_Root := Ocarina.Parser.Parse
        (AADL_Language, Interface_Root, B);

      if Generate_Glue then
         if Depl_View_Pos = 0 then
            Set_Str_To_Name_Buffer ("DeploymentView.aadl");
         else
            Set_Str_To_Name_Buffer (Ada.Command_Line.Argument (Depl_View_Pos));
         end if;

         FN := Ocarina.Files.Search_File (Name_Find);
         B := Ocarina.Files.Load_File (FN);
         Deployment_Root := Ocarina.Parser.Parse
           (AADL_Language, Deployment_Root, B);

         if Deployment_Root = No_Node then
            raise AADL_Parser_Error with "Deployment View is incorrect";
         end if;
      end if;

      --  Missing data view is actually not an error.
      --  Systems can live with parameterless messages
      if Data_View > 0 then
         Set_Str_To_Name_Buffer (Ada.Command_Line.Argument (Data_View));
         FN := Ocarina.Files.Search_File (Name_Find);
         if FN = No_Name then
            raise AADL_Parser_Error with "Cannot find the Data View file";
         end if;
      else
         --  Try with default name
         Set_Str_To_Name_Buffer ("DataView.aadl");
         FN := Ocarina.Files.Search_File (Name_Find);
      end if;
      if FN /= No_Name then
         B := Ocarina.Files.Load_File (FN);
         Interface_Root := Ocarina.Parser.Parse
           (AADL_Language, Interface_Root, B);
         if Deployment_Root /= No_Node then
            Deployment_Root := Ocarina.Parser.Parse
               (AADL_Language, Deployment_Root, B);
         end if;
         Dataview_root := Ocarina.Parser.Parse
                            (AADL_Language, Dataview_root, B);
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

   Initialize;

   --  First, we analyze the interface view.

   Ocarina.Options.Root_System_Name :=
          Get_String_Name ("interfaceview.others");

   IV_Root := Root_System (Instantiate_Model (Root => Interface_Root));
   IV_AST := Parse_Interface_View (IV_Root);

   IV_AST.Debug_Dump;

   --  Now, we are done with the interface view. We now analyze the
   --  deployment view.

   if Depl_View_Pos > 0 then
      AADL_Lib.Append (Ada.Command_Line.Argument (Interface_View));
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

   when E : others =>
      Errors.Display_Bug_Box (E);
end AADL_Parser;
