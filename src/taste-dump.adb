--  *************************** kazoo ***********************  --
--  (c) 2019 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

with Ada.Directories,
     Ada.Text_IO,
     Ada.Characters.Latin_1,
     Ada.Exceptions,
     Ada.Strings.Unbounded,
     Templates_Parser,
     TASTE.Parser_Utils,
     TASTE.Backend.Code_Generators;

use Ada.Directories,
    Ada.Text_IO,
    Ada.Strings.Unbounded,
    Templates_Parser,
    TASTE.Parser_Utils,
    TASTE.Backend.Code_Generators;

package body TASTE.Dump is

   Newline : Character renames Ada.Characters.Latin_1.LF;

   --  iterate over template folders in the dump directory
   procedure Dump_Input_Model (Model : TASTE_Model)
   is
      IV : constant IV_As_Template :=
        Interface_View_Template (Model.Interface_View);

      --  Everything will be generated under output/Dump
      --  There may be subfolders inside, set by the templates
      Output_Prefix : constant String :=
        Model.Configuration.Output_Dir.Element & "/Dump";

      --  Root path containing the template subfolders:
      Prefix   : constant String :=
        Model.Configuration.Binary_Path.Element & "templates/dump";

      --  To iterate over template folders
      ST       : Search_Type;
      Current  : Directory_Entry_Type;
      Filter   : constant Filter_Type := (Directory => True,
                                          others    => False);
      Output_File      : File_Type;

      --  Tags that are built over the whole system
      --  and cleant up between each template folder:
   begin
      Put_Debug ("Folder with Dump templates: " & Prefix);
      Start_Search (Search    => ST,
                    Pattern   => "",
                    Directory => Prefix,
                    Filter    => Filter);

      if not More_Entries (ST) then
         --  On Unix, this will never happen because "." and ".." are part
         --  of the search result. We'll only get an IO Error if the
         --  dump folder itself does not exist
         raise Dump_Error with
           "No folders with templates to dump input models";
      end if;

      --  Iterate over the folders containing template files
      while More_Entries (ST) loop
         --  Clean-up system-wise tags before the next template folder:

         Get_Next_Entry (ST, Current);

         --  Ignore Unix special directories
         if Simple_Name (Current) = "." or Simple_Name (Current) = ".." then
            goto continue;
         end if;

         declare
            Path          : constant String := Full_Name (Current);
            Path_Template : constant String := Path & "/path.tmplt";
            File_Template : constant String := Path & "/filename.tmplt";
            Trig_Template : constant String := Path & "/trigger.tmplt";
            Out_Template  : constant String := Path & "/output.tmplt";
            IV_Template   : constant String := Path & "/interfaceview.tmplt";
            DV_Template   : constant String := Path & "/deploymentview.tmplt";
            Data_Template : constant String := Path & "/dataview.tmplt";
            Func_Template : constant String := Path & "/function.tmplt";
            IF_Template   : constant String := Path & "/interface.tmplt";
            Node_Template : constant String := Path & "/node.tmplt";
            Part_Template : constant String := Path & "/partition.tmplt";

            --  Verify that all templates files are present
            Check         : constant Boolean :=
              Exists (Path_Template) and then Exists (File_Template)
              and then Exists (Trig_Template) and then Exists (Out_Template)
              and then Exists (IV_Template) and then Exists (DV_Template)
              and then Exists (Data_Template) and then Exists (Func_Template)
              and then Exists (IF_Template) and then Exists (Node_Template)
              and then Exists (Part_Template);

            --  Get the output path and filename from the template,
            --  and evaluate the trigger condition
            --  (in the future it should get the configuration as tags)
            Output_Path   : constant String :=
              (if Check then Strip_String (Parse (Path_Template)) else "");
            Filename      : constant String :=
              (if Check then Strip_String (Parse (File_Template)) else "");
            Trigger       : constant Boolean :=
              (Check and then (Strip_String (Parse (Trig_Template)) = "TRUE"));

            IV_Tags     : Translate_Set;   -- Interface View
            DV_Tags     : Translate_Set;   -- Deployment View
            Output_Tags : Translate_Set;
            Functions   : Unbounded_String;
            Nodes       : Unbounded_String;
            Source_Functions,                  -- Connections in deployment
            Source_Ports,
            Bus_Names,
            Dest_Functions,
            Dest_Ports  : Vector_Tag;

            function Process_Interfaces (Interfaces : Template_Vectors.Vector)
                                         return Unbounded_String
            is
               Result : Unbounded_String;
            begin
               for I of Interfaces loop

                  Result := Result & String'(Parse (IF_Template, I)) & Newline;
               end loop;
               return Result;
            end Process_Interfaces;
         begin
            Document_Template (Prefix, "interfaceview.tmplt", IV_Tags);
            if not Check or not Trigger then
               Put_Info ("Nothing generated from " & Path);
               return;
            else
               Put_Info ("Generating Dump from " & Path);
               --  Prepare the interface view
               for F of IV.Funcs loop
                  declare
                     Func_Map : constant Translate_Set := F.Header
                       & Assoc ("Provided_Interfaces",
                                Process_Interfaces (F.Provided))
                       & Assoc ("Required_Interfaces",
                                Process_Interfaces (F.Required));
                     Result : constant String :=
                       Parse (Func_Template, Func_Map);
                  begin
                     Functions := Functions & Result & Newline;
                  end;
               end loop;

               --  Prepare the deployment view
               for N of Model.Deployment_View.Element.Nodes loop
                  if N.Name = "interfaceview" then
                     goto Next_Node;
                  end if;

                  declare
                     Node_Map           : Translate_Set :=
                       +Assoc  ("Node_Name",      N.Name)
                       & Assoc ("CPU_Name",       N.CPU_Name)
                       & Assoc ("CPU_Platform",   N.CPU_Platform'Img)
                       & Assoc ("CPU_Classifier", N.CPU_Classifier)
                       & Assoc ("Ada_Runtime",    N.Ada_Runtime);
                     Partitions         : Unbounded_String;
                     Device_Names,
                     Package_Names,
                     Device_Classifiers,
                     Proc_Names,
                     Config,
                     Bus_Names,
                     Port_Names,
                     Asn1_Files,
                     Asn1_Typenames,
                     Asn1_Modules       : Vector_Tag;
                  begin
                     for Driver of N.Drivers loop
                        Device_Names   := Device_Names & Driver.Name;
                        Package_Names  := Package_Names & Driver.Package_Name;
                        Device_Classifiers :=
                          Device_Classifiers & Driver.Device_Classifier;
                        Proc_Names     :=
                          Proc_Names & Driver.Associated_Processor_Name;
                        Config         := Config & Driver.Device_Configuration;
                        Bus_Names      := Bus_Names & Driver.Accessed_Bus_Name;
                        Port_Names     :=
                          Port_Names & Driver.Accessed_Port_Name;
                        Asn1_Files     := Asn1_Files & Driver.ASN1_Filename;
                        Asn1_Typenames :=
                          Asn1_Typenames & Driver.ASN1_Typename;
                        Asn1_Modules   := Asn1_Modules & Driver.ASN1_Module;
                     end loop;

                     --  Add drivers to the node map
                     Node_Map := Node_Map
                       & Assoc ("Device_Names",       Device_Names)
                       & Assoc ("Package_Names",      Package_Names)
                       & Assoc ("Device_Classifiers", Device_Classifiers)
                       & Assoc ("Proc_Names",         Proc_Names)
                       & Assoc ("Config",             Config)
                       & Assoc ("Bus_Names",          Bus_Names)
                       & Assoc ("Port_Names",         Port_Names)
                       & Assoc ("Asn1_Files",         Asn1_Files)
                       & Assoc ("Asn1_Typenames",     Asn1_Typenames)
                       & Assoc ("Asn1_Modules",       Asn1_Modules);

                     for P of N.Partitions loop
                        declare
                           Part : constant String :=
                             Parse (Part_Template, P.To_Template);
                        begin
                           Partitions := Partitions & Part & Newline;
                        end;
                     end loop;

                     --  Add partitions to the node map
                     Node_Map := Node_Map & Assoc ("Partitions", Partitions);

                     Nodes :=
                       Nodes & String'(Parse (Node_Template, Node_Map))
                       & Newline;
                  end;
                  <<Next_Node>>
               end loop;

               --  Add the deployment connections as vector tag
               for C of Model.Deployment_View.Element.Connections loop
                  Source_Functions := Source_Functions & C.Source_Function;
                  Source_Ports     := Source_Ports     & C.Source_Port;
                  Bus_Names        := Bus_Names        & C.Bus_Name;
                  Dest_Functions   := Dest_Functions   & C.Dest_Function;
                  Dest_Ports       := Dest_Ports       & C.Dest_Port;
               end loop;
            end if;

            --  Interface view is made of functions and connections
            IV_Tags := +Assoc ("Functions", Functions)
              & Assoc ("Callers", IV.Callers)
              & Assoc ("Callees", IV.Callees)
              & Assoc ("Caller_RIs", IV.RI_Names)
              & Assoc ("Callee_PIs", IV.PI_Names);

            --  Deployment view is made of nodes, connections and busses
            DV_Tags := +Assoc ("Nodes", Nodes)
              & Assoc ("Source_Functions", Source_Functions)
              & Assoc ("Source_Ports", Source_Ports)
              & Assoc ("Bus_Names",    Bus_Names)
              & Assoc ("Dest_Functions",   Dest_Functions)
              & Assoc ("Dest_Ports",   Dest_Ports);

            --  Output is made of interface, deployment and data views
            Document_Template (Prefix, "interfaceview.tmplt", IV_Tags);
            Output_Tags := +Assoc ("Interface_View",
                                   String'(Parse (IV_Template, IV_Tags)))
              & Assoc ("Deployment_View",
                       String'(Parse (DV_Template, DV_Tags)));

            Create_Path (Output_Prefix & "/" & Output_Path);
            Create (File => Output_File,
                    Mode => Out_File,
                    Name =>
                      Output_Prefix & "/" & Output_Path & "/" & Filename);
            Put_Line (Output_File, Parse (Out_Template, Output_Tags));
            Close (Output_File);
         end;

         <<continue>>
      end loop;
      End_Search (ST);
   exception
      when Error : others =>
         Put_Error ("Dump : "
                    & Ada.Exceptions.Exception_Message (Error));
         raise Quit_Taste;
   end Dump_Input_Model;
end TASTE.Dump;
