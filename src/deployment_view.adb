--  *************************** taste aadl parser ***********************  --
--  (c) 2017 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

--  Deployment View parser

with --  Ada.Text_IO,
     --  Ada.Exceptions,
     --  Ocarina.Instances.Queries,
     Ocarina.Backends.Properties,
     Ocarina.Instances,
     Ocarina.Namet,
     Ocarina.Analyzer,
     Ocarina.Options,
     Ocarina.ME_AADL.AADL_Instances.Nodes,
     Ocarina.ME_AADL.AADL_Instances.Nutils,
     Ocarina.ME_AADL.AADL_Instances.Entities;
     --  Ocarina.Backends.Utils;

package body Deployment_View is

   use --  Ada.Text_IO,
       --  Ada.Exceptions,
       --  Ocarina.Instances.Queries,
       Ocarina.Backends.Properties,
       Ocarina.Namet,
       Ocarina.ME_AADL.AADL_Instances.Nodes,
       Ocarina.ME_AADL.AADL_Instances.Nutils,
       Ocarina.ME_AADL.AADL_Instances.Entities,
       Ocarina.ME_AADL;
       --  Ocarina.Backends.Utils;

   function Initialize (Root : Node_Id) return Node_Id is
      Success        : Boolean;
      Root_Instance  : Node_Id;
      AADL_Language  : constant Name_Id := Get_String_Name ("aadl");
   begin
      Success := Ocarina.Analyzer.Analyze (AADL_Language, Root);

      if not Success then
         raise Deployment_View_Error with "Deployment view is incorrect";
      end if;

      Ocarina.Options.Root_System_Name :=
        Get_String_Name ("deploymentview.others");

      --  Instantiate AADL tree
      Root_Instance := Ocarina.Instances.Instantiate_Model (Root => Root);

      return Root_System (Root_Instance);

   end Initialize;

   ---------------------------
   -- AST Builder Functions --
   ---------------------------

   function AADL_To_Ada_DV (System : Node_Id) return Complete_Deployment_View
   is
      use type Node_Maps.Map;
      use type Taste_Busses.Vector;
      Nodes          : Node_Maps.Map;
      Busses         : Taste_Busses.Vector;
      Conns          : Bus_Connections.Vector;
      My_Root_System : Node_Id;
      Subs           : Node_Id;
      CI             : Node_Id;

      function Parse_Bus (Elem : Node_Id; Bus : Node_Id) return Taste_Bus is
         Properties : constant Property_Maps.Map := Get_Properties_Map (CI);
         Classifier : Name_Id := No_Name;
         Pkg_Name   : Name_Id := No_Name;
      begin
         Set_Str_To_Name_Buffer ("");
         if ATN.Namespace
             (Corresponding_Declaration (Bus)) /= No_Node
         then
            Set_Str_To_Name_Buffer ("");
            Get_Name_String (ATN.Name (ATN.Identifier (ATN.Namespace
                             (Corresponding_Declaration (Bus)))));
            Pkg_Name := Name_Find;
            Set_Str_To_Name_Buffer ("");
            Get_Name_String (Pkg_Name);
            Add_Str_To_Name_Buffer ("::");
            Get_Name_String_And_Append
               (Name (Identifier (Bus)));
            Classifier := Name_Find;
         else
            Classifier := Name (Identifier (Bus));
         end if;
         return Taste_Bus'(Name         =>
                             US (Get_Name_String (Name (Identifier (Elem)))),
                           AADL_Package => US (Get_Name_String (Pkg_Name)),
                           Classifier   => US (Get_Name_String (Classifier)),
                           Properties   => Properties);
      end Parse_Bus;

      function Parse_Connections (CI : Node_Id) return Bus_Connections.Vector
      is
         use Bus_Connections;
         Conn           : Node_Id;
         Bound_Bus      : Node_Id;
         Src_Port       : Node_Id;
         Src_Name       : Unbounded_String;
         Dst_Name       : Unbounded_String;
         Dst_Port       : Node_Id;
         Bound_Bus_Name : Name_Id;
         If1_Name       : Name_Id;
         If2_Name       : Name_Id;
         Result         : Bus_Connections.Vector;
      begin
         Conn := First_Node (Connections (CI));
         while Present (Conn) loop
            Bound_Bus := Get_Bound_Bus (Conn, False);
            if Bound_Bus /= No_Node then
               Bound_Bus_Name := Name
                  (Identifier (Parent_Subcomponent (Bound_Bus)));
               Src_Port := Get_Referenced_Entity (Source (Conn));
               Dst_Port := Get_Referenced_Entity (Destination (Conn));
               If1_Name := Get_Interface_Name (Src_Port);
               If2_Name := Get_Interface_Name (Dst_Port);
               --  Get_Interface_Name is v1.3.5+ only
               if If1_Name /= No_Name and If2_Name /= No_Name then
                  Src_Name := US (Get_Name_String (If1_Name));
                  Dst_Name := US (Get_Name_String (If2_Name));
               else
                  --  Keep compatibility with v1.2
                  Src_Name := US (Get_Name_String (Display_Name
                                                  (Identifier (Src_Port))));

                  Dst_Name := US (Get_Name_String (Display_Name
                                                  (Identifier (Dst_Port))));
               end if;
               Result := Result
                 & Bus_Connection'(Source_Node => Src_Name,
                                   Source_Port => US (Get_Name_String
                                     (Name (Identifier
                                      (Parent_Subcomponent
                                           (Parent_Component (Src_Port)))))),
                                   Bus_Name    =>
                                     US (Get_Name_String (Bound_Bus_Name)),
                                   Dest_Node   => Dst_Name,
                                   Dest_Port   => US (Get_Name_String
                                     (Name (Identifier
                                      (Parent_Subcomponent
                                           (Parent_Component (Src_Port)))))));
            end if;
            Conn := Next_Node (Conn);
         end loop;
         return Result;
      end Parse_Connections;

   begin
      My_Root_System := Initialize (System);

      if Is_Empty (Subcomponents (My_Root_System)) then
         raise Empty_Deployment_View_Error;
      end if;

      Subs := First_Node (Subcomponents (My_Root_System));

      while Present (Subs) loop
         CI := Corresponding_Instance (Subs);

         if Get_Category_Of_Component (CI) = CC_System then
            if not Is_Empty (Connections (CI)) then
               Conns := Parse_Connections (CI);
            end if;

--            Browse_Deployment_View_System
--                (CI, Get_Name_String (Name (Identifier (Subs))));
         elsif Get_Category_Of_Component (CI) = CC_Bus then
            Busses.Append (Parse_Bus (Subs, CI));
         end if;
         Subs := Next_Node (Subs);
      end loop;

      return DV_AST : constant Complete_Deployment_View :=
        (Nodes          => Nodes,
         Connections    => Conns,
         Busses         => Busses);
   end AADL_To_Ada_DV;

   procedure Debug_Dump_DV (DV : Complete_Deployment_View) is null;
end Deployment_View;
