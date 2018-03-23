with Ada.Strings.Unbounded,
     TASTE.Deployment_View,
     TASTE.Parser_Utils;

use Ada.Strings.Unbounded,
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
         end loop;
      end if;
   end Check_Model;

end TASTE.Semantic_Check;
