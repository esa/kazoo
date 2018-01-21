with Text_IO,
     Templates_Parser;
use  Text_IO,
     Templates_Parser;

package body TASTE.Backend.Skeletons.C is
   procedure Generate (Config   : Taste_Configuration;
                       Template : Translate_Set) is
      dummy_Prefix : constant String := Config.Binary_Path.all
        & "templates/skeletons/c";
   begin
      null;
   end Generate;
end TASTE.Backend.Skeletons.C;
