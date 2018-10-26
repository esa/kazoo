--  *************************** taste aadl parser ***********************  --
--  (c) 2018 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

--  Concurrency View

package body TASTE.Concurrency_View is

   procedure Debug_Dump (CV : Taste_Concurrency_View; Output : File_Type) is
   begin
      for Each of CV.Blocks loop
         Put_Line (Output, "Protected Block : " & To_String (Each.Name));
      end loop;

      for Each of CV.Threads loop
         Put_Line (Output, "Thread : " & To_String (Each.Name));
      end loop;
   end Debug_Dump;

end TASTE.Concurrency_View;
