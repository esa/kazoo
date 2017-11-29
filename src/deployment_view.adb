--  *************************** taste aadl parser ***********************  --
--  (c) 2017 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

--  Deployment View parser

with --  Ada.Text_IO,
     --  Ada.Exceptions,
     --  Ocarina.Instances.Queries,
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
            Get_Name_String
               (ATN.Name
                  (ATN.Identifier
                     (ATN.Namespace
                        (Corresponding_Declaration (Bus)))));
            Pkg_Name := Name_Find;
            --  C_Add_Package
            --   (Get_Name_String (Pkg_Name),

            Set_Str_To_Name_Buffer ("");
            Get_Name_String (Pkg_Name);
            Add_Str_To_Name_Buffer ("::");
            Get_Name_String_And_Append
               (Name (Identifier (Bus)));
            Classifier := Name_Find;
         else
            Classifier := Name (Identifier (Bus));
         end if;
         return Taste_Bus'(Name       =>
                             US (Get_Name_String (Name (Identifier (Elem)))),
                           Classifier => US (Get_Name_String (Classifier)),
                           Properties => Properties);
      end Parse_Bus;

   begin
      My_Root_System := Initialize (System);

      if Is_Empty (Subcomponents (My_Root_System)) then
         raise Empty_Deployment_View_Error;
      end if;

      Subs := First_Node (Subcomponents (My_Root_System));

      while Present (Subs) loop
         CI := Corresponding_Instance (Subs);

         if Get_Category_Of_Component (CI) = CC_System then
            null;
--            Browse_Deployment_View_System
--                (CI, Get_Name_String (Name (Identifier (Subs))));
         elsif Get_Category_Of_Component (CI) = CC_Bus then
            Busses.Append (Parse_Bus (Subs, CI));

         end if;
         Subs := Next_Node (Subs);
      end loop;

      return DV_AST : constant Complete_Deployment_View :=
        (Nodes          => Nodes,
         Busses         => Busses);
   end AADL_To_Ada_DV;

   procedure Debug_Dump_DV (DV : Complete_Deployment_View) is null;
end Deployment_View;
