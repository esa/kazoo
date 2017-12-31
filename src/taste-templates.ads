with Ada.Strings.Unbounded,
     Templates_Parser;
use  Ada.Strings.Unbounded,
     Templates_Parser;

package TASTE.Templates is

   procedure New_Set;

   procedure Map (Name : String; Value : String);
   procedure Map (Name : String; Value : Boolean);
   procedure Map (Name : String; Value : Unbounded_String);
   procedure Map (Name : String; Value : Integer);
   procedure Map (Name : String; Value : Tag);

   function Generate (Template_File : String) return String;
private
   Tmpl_Set : Translate_Set;

end TASTE.Templates;
