with Ada.Strings.Unbounded,
     Templates_Parser;
use  Ada.Strings.Unbounded,
     Templates_Parser;

package TASTE.Templates is

   procedure New_Set;

   procedure Tmpl_Map (Name : String; Value : String);
   procedure Tmpl_Map (Name : String; Value : Boolean);
   procedure Tmpl_Map (Name : String; Value : Unbounded_String);
   procedure Tmpl_Map (Name : String; Value : Integer);
   procedure Tmpl_Map (Name : String; Value : Tag);

   function Generate (Template_File : String) return String;
private
   Tmpl_Set : Translate_Set;

end TASTE.Templates;
