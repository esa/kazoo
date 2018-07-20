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
      Count_Active_PI  : Natural := 0;
      Count_Passive_PI : Natural := 0;
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
            declare
               New_F    : Taste_Terminal_Function :=
                             (Name     => F.Name & "_" & PI.Name,
                              Language => US ("blackbox_device"),
                              Context  => F.Name,
                              Required => F.Required, --  Inherit from RIs
                              others   => <>);
               New_F_PI : Taste_Interface := PI;
               New_F_RI : Taste_Interface := PI;
            begin
               New_F_PI.Parent_Function := New_F.Name;

               --  Set the name of the RI of the newly created function
               --  (avoid keeping the same name as the PI)
               New_F_RI.Name := (if   PI.RCM = Cyclic_Operation
                                 then "CYC_" & PI.Name
                                 else "SPO_" & PI.Name);

               --  Connect the new function's RI to the PI of the old function
               New_F_RI.Remote_Interfaces.Clear;
               New_F_RI.Remote_Interfaces.Append
                  (Remote_Entity'(Function_Name  => F.Name,
                                  Interface_Name => PI.Name));
               --  The Remote interface of the new PI are inherited from PI

               --  NOTE: The remote interfaces of the callers of the PI will be
               --  updated after the creation of all new functions, at model
               --  level.

               --  Change the nature of the PI that triggered a new function
               --  (Unprotected if the function only contained one active PI,
               --  and possibly any number of other unprotected PIs)
               PI.RCM := (if   Count_Active_PI > 1
                          then Protected_Operation
                          else Unprotected_Operation);

               --  Replace the remotes of the PI with the new function
               --  (They were copied to the PI of the new function)
               PI.Remote_Interfaces.Clear;
               PI.Remote_Interfaces.Append
                  (Remote_Entity'(Function_Name  => New_F.Name,
                                  Interface_Name => New_F_RI.Name));

               --  Add the PI and RI to the new function
               New_F.Provided.Insert (Key      => To_String (PI.Name),
                                      New_Item => New_F_PI);
               New_F.Required.Insert (Key      => To_String (New_F_RI.Name),
                                      New_Item => New_F_RI);

               --  Make sure the parent function of all RIs is set
               for RI of New_F.Required loop
                  RI.Parent_Function := New_F.Name;
               end loop;

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
      Functions     : Function_Maps.Map
         renames Result.Interface_View.Flat_Functions;
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

      --  Update the PI/RI connections of the existing functions:
      --  For each PI and RI of newly-created function, look for all remote
      --  functions, and find the corresponding PI or RI
      --  Then replace the old remote function with the new one
      for F of New_Functions loop
         for PI of F.Provided loop
            for Remote of PI.Remote_Interfaces loop
               declare
                  Remote_Function  : constant Function_Maps.Cursor :=
                     Functions.Find (To_String (Remote.Function_Name));
                  Corresponding_RI : constant Interfaces_Maps.Cursor :=
                     Functions (Remote_Function).Required.Find
                        (To_String (Remote.Interface_Name));
               begin
                  for RI_Remote of Functions (Remote_Function).Required
                     (Corresponding_RI).Remote_Interfaces
                  loop
                     if RI_Remote.Function_Name = F.Context then
                        RI_Remote.Function_Name := F.Name;
                     end if;
                  end loop;
               end;
            end loop;
         end loop;

         for RI of F.Required loop
            for Remote of RI.Remote_Interfaces loop
               declare
                  Remote_Function  : constant Function_Maps.Cursor :=
                     Functions.Find (To_String (Remote.Function_Name));
                  Corresponding_PI : constant Interfaces_Maps.Cursor :=
                     Functions (Remote_Function).Provided.Find
                        (To_String (Remote.Interface_Name));
               begin
                  for PI_Remote of Functions (Remote_Function).Provided
                     (Corresponding_PI).Remote_Interfaces
                  loop
                     if PI_Remote.Function_Name = F.Context then
                        PI_Remote.Function_Name := F.Name;
                     end if;
                  end loop;
               end;
            end loop;

         end loop;

         --  Add the function to the deployment view
         for Node of Result.Deployment_View.Nodes loop
            for Partition of Node.Partitions loop
               if Partition.Bound_Functions.Contains (To_String (F.Context))
               then
                  begin
                     Partition.Bound_Functions.Insert (To_String (F.Name));
                  exception
                     when Constraint_Error =>
                        --  Insert error, value already exists in the set
                        Put_Error ("Vertical Transformation Error: generated "
                           & "name conflicts with user function "
                           & To_String (F.Name));
                  end;
               end if;
            end loop;
         end loop;

         --  Finally, add all newly-created functions to the new model
         Result.Interface_View.Flat_Functions.Insert
                                               (Key      => To_String (F.Name),
                                                New_Item => F);
      end loop;

      return Result;
   end Transform;
end TASTE.Model_Transformations;
