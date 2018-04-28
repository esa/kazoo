package body TASTE.Model_Transformations is
   function Transform (Model : TASTE_Model) return TASTE_Model is
      Result : constant TASTE_Model := Model;
   begin
      return Result;
   end Transform;
end TASTE.Model_Transformations;
