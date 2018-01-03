package body TASTE.Templates is

   procedure New_Set is
   begin
      Tmpl_Set := Null_Set;
   end New_Set;

   procedure Tmpl_Map (Name : String; Value : String) is
   begin
      Tmpl_Set := Tmpl_Set & Assoc (Name, Value);
   end Tmpl_Map;

   procedure Tmpl_Map (Name : String; Value : Boolean) is
   begin
      Tmpl_Set := Tmpl_Set & Assoc (Name, Value);
   end Tmpl_Map;

   procedure Tmpl_Map (Name : String; Value : Unbounded_String) is
   begin
      Tmpl_Set := Tmpl_Set & Assoc (Name, Value);
   end Tmpl_Map;

   procedure Tmpl_Map (Name : String; Value : Integer) is
   begin
      Tmpl_Set := Tmpl_Set & Assoc (Name, Value);
   end Tmpl_Map;

   procedure Tmpl_Map (Name : String; Value : Tag) is
   begin
      Tmpl_Set := Tmpl_Set & Assoc (Name, Value);
   end Tmpl_Map;

   function Generate (Template_File : String) return String is
     (Parse (Template_File, Tmpl_Set));
begin
      Set_Tag_Separators (Start_With => "<",
                          Stop_With  => ">");
end TASTE.Templates;
