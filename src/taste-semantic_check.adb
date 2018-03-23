with Ada.Strings.Unbounded,
     Ada.Containers,
     Ocarina.Backends.Properties,
     TASTE.Deployment_View,
     TASTE.Parser_Utils;

use Ada.Strings.Unbounded,
    Ada.Containers,
    Ocarina.Backends.Properties,
    TASTE.Deployment_View,
    TASTE.Parser_Utils;

package body TASTE.Semantic_Check is
   procedure Check_Model (Model : TASTE_Model) is
      use Option_Partition;
      Opt_Part : Option_Partition.Option;
   begin
      if Model.Configuration.Glue then
         for Each of Model.Interface_View.Flat_Functions loop
            Opt_Part := Model.Find_Binding (Each.Name);
            --  Check that each function is placed on a partition
            if not Each.Is_Type and then not Opt_Part.Has_Value then
               raise Semantic_Error with
                "In the deployment view, the function " & To_String (Each.Name)
                & " is not bound to any partition!";
            end if;

            --  Check that functions have at least one PI
            --  with the exception of GUIs and Blackbox devices
            if Each.Language /= Language_Gui
               and then Each.Language /= Language_Device
               and then Each.Provided.Length = 0
            then
               raise Semantic_Error with
                  "Function " & To_String (Each.Name) & " has no provided "
                  & "interfaces, and dead code is not allowed";
            end if;

         end loop;
      end if;
   end Check_Model;

end TASTE.Semantic_Check;
