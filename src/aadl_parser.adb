--  ************************ TASTE AADL Parser **************************  --
--  Based on Ocarina ****************************************************  --
--  (c) 2017 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file
pragma Warnings (Off);
with Ada.Strings.Unbounded,
     Ada.Command_Line,
     Ada.Exceptions,
     Ada.Text_IO,
     Ada.Containers.Indefinite_Vectors,
     GNAT.OS_Lib,
     Errors,
     Locations,
     Ocarina.Namet,
     Ocarina.Types,
     Ocarina.Analyzer,
     Ocarina.Backends.Properties,
     Ocarina.Configuration,
     Ocarina.Files,
     Ocarina.Options,
     Ocarina.Instances,
     Ocarina.ME_AADL.AADL_Instances.Entities,
     Ocarina.ME_AADL.AADL_Instances.Nodes,
     Ocarina.ME_AADL.AADL_Instances.Nutils,
     Ocarina.Parser,
     Ocarina.FE_AADL.Parser,
     Parser_Utils,
     Interface_View,
     Deployment_View;

use Ada.Strings.Unbounded,
    Ada.Text_IO,
    Ada.Exceptions,
    Locations,
    Ocarina.Namet,
    Ocarina.Types,
    Ocarina,
    Ocarina.Analyzer,
    Ocarina.Backends.Properties,
    Ocarina.Instances,
    Ocarina.ME_AADL,
    Ocarina.ME_AADL.AADL_Instances.Entities,
    Ocarina.ME_AADL.AADL_Instances.Nodes,
    Ocarina.ME_AADL.AADL_Instances.Nutils,
    Ocarina.Backends.Properties,
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
   OutDir            : Integer := 0;
   Stack_Val         : Integer := 0;
   Timer_Resolution  : Integer := 0;
   Interface_View    : Integer := 0;
   Depl_View_Pos : Integer := 0;
   Data_View         : Integer := 0;
   Generate_glue     : Boolean := false;
   Keep_case         : Boolean := false;
   AADL_Version      : AADL_Version_Type := Ocarina.AADL_V2;

   procedure Parse_Command_Line;
   --  procedure Process_DataView (My_Root : Node_Id);
   procedure Browse_Deployment_View_System
     (My_System : Node_Id; NodeName : String) with Unreferenced;

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

   procedure Browse_Deployment_View_System
       (My_System : Node_Id; NodeName : String) is
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
   begin
      null;
--     if not Is_Empty (Subcomponents (My_System)) then
--        C_New_Drivers_Section;
--        Processes := First_Node (Subcomponents (My_System));
--
--        while Present (Processes) loop
--           Tmp_CI := Corresponding_Instance (Processes);
--
--           if Get_Category_Of_Component (Tmp_CI) = CC_Process then
--              declare
--                 Node_Coverage : Boolean := False;
--              begin
--                 if Is_Defined_Property (Tmp_CI,
--                                      "taste_dv_properties::coverageenabled")
--                 then
--                    Node_Coverage := Get_Boolean_Property
--                       (Tmp_CI,
--                   Get_String_Name ("taste_dv_properties::coverageenabled"));
--                    if Node_Coverage then
--                       Put_Line ("Needs Coverage");
--                    else
--                       Put_Line ("Needs No coverage");
--                    end if;
--                 end if;
--
--                 CPU := Get_Bound_Processor (Tmp_CI);
--                 Set_Str_To_Name_Buffer ("");
--                 CPU_Name := Name (Identifier (Parent_Subcomponent (CPU)));
--
--                 CPU_Platform := Get_Execution_Platform (CPU);
--
--                if ATN.Namespace (Corresponding_Declaration (CPU)) /= No_Node
--                 then
--                    Set_Str_To_Name_Buffer ("");
--                    Get_Name_String
--                       (ATN.Name
--                          (ATN.Identifier
--                             (ATN.Namespace
--                                (Corresponding_Declaration (CPU)))));
--                    Pkg_Name := Name_Find;
--                    C_Add_Package
--                       (Get_Name_String (Pkg_Name),
--                       Get_Name_String (Pkg_Name)'Length);
--                    Set_Str_To_Name_Buffer ("");
--                    Get_Name_String (Pkg_Name);
--                    Add_Str_To_Name_Buffer ("::");
--                    Get_Name_String_And_Append (Name (Identifier (CPU)));
--                    CPU_Classifier := Name_Find;
--                 else
--                    CPU_Classifier := Name (Identifier (CPU));
--                 end if;
--
--                 C_New_Processor
--                    (Get_Name_String (CPU_Name),
--                    Get_Name_String (CPU_Name)'Length,
--                    Get_Name_String (CPU_Classifier),
--                    Get_Name_String (CPU_Classifier)'Length,
--                    Supported_Execution_Platform'Image (CPU_Platform),
--                   Supported_Execution_Platform'Image (CPU_Platform)'Length);
--
--                 C_New_Process
--                    (Get_Name_String
--                       (ATN.Name
--                          (ATN.Component_Type_Identifier
--                             (Corresponding_Declaration (Tmp_CI)))),
--                     Get_Name_String
--                       (ATN.Name
--                          (ATN.Component_Type_Identifier
--                             (Corresponding_Declaration (Tmp_CI))))'Length,
--                    Get_Name_String (Name (Identifier (Processes))),
--                    Get_Name_String (Name (Identifier (Processes)))'Length,
--                    NodeName, NodeName'Length,
--                    Boolean'Pos (Node_Coverage));
--
--                 Processes2 := First_Node (Subcomponents (My_System));
--
--                 while Present (Processes2) loop
--                    Tmp_CI2 := Corresponding_Instance (Processes2);
--
--                    if Get_Category_Of_Component (Tmp_CI2) = CC_System
--                       and then
--                       Is_Defined_Property
--                          (Tmp_CI2, "taste::aplc_binding")
--                    then
--                       Ref := Get_Reference_Property
--                          (Tmp_CI2, Get_String_Name ("taste::aplc_binding"));
--
--                       if Ref = Tmp_CI then
--                          declare
--                             Bound_APLC_Name : Unbounded_String;
--                          begin
--                             begin
--                                Bound_APLC_Name := US
--                                  (Get_Name_String
--                                    (ATN.Name
--                                      (ATN.Component_Type_Identifier
--                                    (Corresponding_Declaration (Tmp_CI2)))));
--                             exception
--                                when System.Assertions.Assert_Failure =>
--                                   Put_Line
--                                      ("Detected DV from TASTE version 1.2");
--                                   Bound_APLC_Name := US
--                                     (Get_Name_String
--                                        (Name (Identifier (Processes2))));
--                             end;
--
--                             C_Add_Binding
--                                (To_String (Bound_APLC_Name),
--                                 To_String (Bound_APLC_Name)'Length);
--                          end;
--                       end if;
--                    end if;
--
--                    Processes2 := Next_Node (Processes2);
--                 end loop;
--
--                 C_End_Process;
--              end;
--           end if;
--
--           Processes := Next_Node (Processes);
--        end loop;
--        C_End_Drivers_Section;
--     end if;
   end Browse_Deployment_View_System;

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
            OutDir := J;
            Previous_OutDir := false;

         elsif Previous_TimerRes then
            Timer_Resolution := J;
            Previous_TimerRes := false;

         elsif Ada.Command_Line.Argument (J) = "--polyorb-hi-c"
           or else Ada.Command_Line.Argument (J) = "-p"
           or else Ada.Command_Line.Argument (J) = "-polyorb-hi-c"
         then
            null;

         elsif Ada.Command_Line.Argument (J) = "--keep-case"
           or else Ada.Command_Line.Argument (J) = "-j"
           or else Ada.Command_Line.Argument (J) = "-keep-case"
         then
            Keep_case := true;

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
            Exit_On_Error (FN = No_Name, "File not found: "
                          & Ada.Command_Line.Argument (J));
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
         S : constant GNAT.OS_Lib.String_Access
           := GNAT.OS_Lib.Locate_Exec_On_Path ("ocarina");
      begin
         Exit_On_Error (S = null,
            "Ocarina is not in your PATH");
         GNAT.OS_Lib.Setenv ("OCARINA_PATH", S.all (S'First .. S'Last - 12));
      end;

      --  Display the command line syntax

      if Ada.Command_Line.Argument_Count = 0 then
         Usage;
         OS_Exit (1);
      end if;

      Ocarina.Initialize;
      Ocarina.AADL_Version := AADL_Version;

      Ocarina.Configuration.Init_Modules;
--      Ocarina.FE_AADL.Parser.First_Parsing := True;
      Ocarina.FE_AADL.Parser.Add_Pre_Prop_Sets := True;
      AADL_Language := Get_String_Name ("aadl");

      Parse_Command_Line;

      Exit_On_Error (Interface_View = 0, "Missing Interface view!");
      Set_Str_To_Name_Buffer (Ada.Command_Line.Argument (Interface_View));
      FN := Ocarina.Files.Search_File (Name_Find);
      Exit_On_Error (FN = No_Name, "Missing Interface view!");
      B := Ocarina.Files.Load_File (FN);
--     C_Set_Interfaceview
--      (Ada.Command_Line.Argument (Interface_View),
--       Ada.Command_Line.Argument (Interface_View)'Length);
      Interface_Root := Ocarina.Parser.Parse
        (AADL_Language, Interface_Root, B);

      if Depl_View_Pos = 0 and Generate_Glue then
         Put_Line ("Fatal error: Missing Deployment view!");
         Put_Line ("Use the '-c file.aadl' parameter.");
         Put_Line
            ("Note: the generation of glue code is invoked automatically");
         Put_Line
            ("from the TASTE orchestrator. You should run taste-aadl-parser");
         Put_Line
            ("only to generate your application skeletons ('-gw' flag).");
         New_line;

      elsif Depl_View_Pos > 0 and Generate_Glue then
         Set_Str_To_Name_Buffer (Ada.Command_Line.Argument (Depl_View_Pos));
         FN := Ocarina.Files.Search_File (Name_Find);
         B := Ocarina.Files.Load_File (FN);
         Deployment_Root := Ocarina.Parser.Parse
           (AADL_Language, Deployment_Root, B);
         Exit_On_Error (Deployment_Root = No_Node,
              "Deployment view is incorrect");
      end if;

      --  Missing data view is actually not an error.
      --  Systems can live with parameterless messages
      --  Exit_On_Error (Data_view = 0, "Error: Missing Data view!");
      if Data_View > 0 then
         Set_Str_To_Name_Buffer (Ada.Command_Line.Argument (Data_View));
         FN := Ocarina.Files.Search_File (Name_Find);

         Exit_On_Error (FN = No_Name, "Cannot find Data View");
--        C_Set_Dataview
--           (Ada.Command_Line.Argument (Data_View),
--           Ada.Command_Line.Argument (Data_View)'Length);
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

      Exit_On_Error (No (Interface_Root), "AADL Parser Internal error");

      --  Analyze the tree

      Success := Ocarina.Analyzer.Analyze (AADL_Language, Interface_Root);
      Exit_On_Error (not Success, "Cannot analyze model.");

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

   Debug_Dump_IV (IV_AST);

   --  Now, we are done with the interface view. We now analyze the
   --  deployment view.

   if Depl_View_Pos > 0 then
      AADL_Lib.Append (Ada.Command_Line.Argument (Interface_View));
      DV_AST := Parse_Deployment_View (Deployment_Root);
   end if;

   Ocarina.Configuration.Reset_Modules;
   Ocarina.Reset;

exception
   when Error : AADL_Parser_Error
      | Deployment_View_Error
      | Device_Driver_Error =>
      Put (Red_Bold & "[ERROR] " & White_Bold);
      Put_Line (Exception_Message (Error) & No_Color);
      OS_Exit (1);

   when E : others =>
      Errors.Display_Bug_Box (E);
end AADL_Parser;
