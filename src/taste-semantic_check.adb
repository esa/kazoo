with Ada.Strings.Unbounded,
     Ada.Containers,
     Ocarina.Backends.Properties,
     TASTE.Deployment_View,
     TASTE.Interface_View,
     TASTE.Parser_Utils;

use Ada.Strings.Unbounded,
    Ada.Containers,
    Ocarina.Backends.Properties,
    TASTE.Deployment_View,
    TASTE.Interface_View,
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

            --  Check that Simulink functions have exactly one PI and no RI
            if (case Each.Language is
               when
                 Language_Simulink | Language_QGenAda | Language_QGenC => True,
               when others => False) and then
               (Each.Provided.Length /= 1 or Each.Required.Length /= 0)
            then
               raise Semantic_Error with
                  "Function " & To_String (Each.Name) & " must contain only "
                  & "one Provided Interface and no Required Interfaces";
            end if;

            --  Check that Simulink/QGen functions's PI is synchronous
            if (case Each.Language is
               when
                 Language_Simulink | Language_QGenAda | Language_QGenC => True,
               when others => False)
            then
               for PI of Each.Provided loop
                  if PI.RCM /= Unprotected_Operation
                     and PI.RCM /= Protected_Operation
                  then
                     raise Semantic_Error with "The provided interface of "
                     & "function " & To_String (Each.Name) & " must be either"
                     & " protected or unprotected, but not sporadic or cyclic";
                  end if;
               end loop;
            end if;

         end loop;
      end if;
   end Check_Model;

end TASTE.Semantic_Check;
