with Ada.Containers,
     Ocarina.Backends.Properties,
     TASTE.Parser_Utils;
use  Ada.Containers,
     Ocarina.Backends.Properties,
     TASTE.Parser_Utils;

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Text_IO; use Text_IO;

package body TASTE.Model_Transformations is

   function Process_Function (F : in out Taste_Terminal_Function)
      return Function_Maps.Map
   is
      New_Functions    : Function_Maps.Map;
      Count_Active_PI  : Natural := 0;
      Count_Passive_PI : Natural := 0;
   begin
      --  Look for GUIs and add a Poll PI (if there is at least one RI)
      if F.Required.Length > 0 and F.Language = Language_GUI then
         F.Provided.Insert (Key      => "Poll",
                            New_Item => (Name            => US ("Poll"),
                                         Parent_Function => F.Name,
                                         RCM             => Cyclic_Operation,
                                         Period_Or_MIAT  => 10,
                                         others => <>));
      end if;

      --  Count the number of Active (Cyclic, Sporadic, Protected) and Passive
      --  provided interfaces of a function ; this is needed for some model
      --  transformations.
      for PI of F.Provided loop
         if PI.RCM = Unprotected_Operation then
            Count_Passive_PI := Count_Passive_PI + 1;
         else
            Count_Active_PI  := Count_Active_PI + 1;
         end if;
      end loop;

      --  When a function contains several active interfaces, create a new
      --  separate function for each of them; this is needed to keep the
      --  system analyzable by having a 1-to-1 mapping between a function and
      --  a thread.
      for PI of F.Provided loop
         if (PI.RCM = Cyclic_Operation or PI.RCM = Sporadic_Operation)
             and then Count_Passive_PI + Count_Active_PI > 1
         then
            --  Create a separate function to handle this PI
            --  It will be later translated into a thread
            declare
               New_F    : Taste_Terminal_Function :=
                             (Name     => F.Name & "_" & PI.Name,
                              Language => Language_Device,
                              Context  => F.Context,
                              others   => <>);
               New_F_PI : Taste_Interface := PI;
               New_F_RI : Taste_Interface := PI;
            begin
               New_F_PI.Parent_Function := New_F.Name;
               New_F_RI.Parent_Function := New_F.Name;

               New_F.Provided.Insert (Key      => To_String (PI.Name),
                                      New_Item => New_F_PI);
               New_F.Required.Insert (Key      => To_String (New_F_RI.Name),
                                      New_Item => New_F_RI);

               --  Add to the list of newly created functions
               New_Functions.Insert (Key      => To_String (New_F.Name),
                                     New_Item => New_F);
            end;
         end if;
      end loop;

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
            Functions : constant Function_Maps.Map := Process_Function (F);
         begin
            for Each of Functions loop
               New_Functions.Insert (Key      => To_String (Each.Name),
                                     New_Item => Each);
            end loop;
         end;
      end loop;

      --  Add all newly-created functions to the new model
      for F of New_Functions loop
         Result.Interface_View.Flat_Functions.Insert
                                               (Key      => To_String (F.Name),
                                                New_Item => F);
      end loop;

      --  Test / Debug:
      for F of Result.Interface_View.Flat_Functions loop
         if F.Language = Language_GUI then
            for I of F.Provided loop
               Put_Line (To_String (I.Name));
            end loop;
         end if;
      end loop;

      return Result;
   end Transform;
end TASTE.Model_Transformations;
