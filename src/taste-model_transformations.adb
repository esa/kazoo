with Ada.Containers,
     --  Ocarina.Backends.Properties,
     TASTE.Parser_Utils;
use  Ada.Containers,
     --  Ocarina.Backends.Properties,
     TASTE.Parser_Utils;

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
--  with Text_IO; use Text_IO;

package body TASTE.Model_Transformations is

   function Process_Function (F : in out Taste_Terminal_Function)
      return Function_Maps.Map
   is
      New_Functions    : Function_Maps.Map;
   begin
      --  Look for GUIs and add a Poll PI (if there is at least one RI)
      if F.Required.Length > 0 and F.Language = "gui" then
         F.Provided.Insert (Key      => "Poll",
                            New_Item => (Name            => US ("Poll"),
                                         Parent_Function => F.Name,
                                         RCM             => Cyclic_Operation,
                                         Period_Or_MIAT  => 10,
                                         others => <>));
      end if;
      return New_Functions;
   end Process_Function;

   function Transform (Model : TASTE_Model) return TASTE_Model is
      Result        : TASTE_Model := Model;
      New_Functions : Function_Maps.Map;
   begin
      --  Processing of user-defined functions (may return a list of new
      --  functions that will be added to the model)
      for F of Result.Interface_View.Flat_Functions loop
         declare
            Funcs : constant Function_Maps.Map := Process_Function (F);
         begin
            for Each of Funcs loop
               New_Functions.Insert (Key      => To_String (Each.Name),
                                     New_Item => Each);
            end loop;
         end;
      end loop;
      return Result;
   end Transform;
end TASTE.Model_Transformations;
