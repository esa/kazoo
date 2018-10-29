--  *************************** taste aadl parser ***********************  --
--  (c) 2018 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

--  Concurrency View

package body TASTE.Concurrency_View is

   procedure Debug_Dump (CV : Taste_Concurrency_View; Output : File_Type) is
   begin
      for Block of CV.Blocks loop
         Put_Line (Output, "Protected Block : " & To_String (Block.Name));
         for Provided of Block.Provided loop
            Put_Line (Output, " |_ PI : " & To_String (Provided.Name));
         end loop;
         for Required of Block.Required loop
            Put_Line (Output, " |_ RI : " & To_String (Required.Name));
         end loop;
         for Thread of Block.Calling_Threads loop
            Put_Line (Output, " |_ Calling_Thread : " & Thread);
         end loop;
         Put_Line (Output, " |_ Node : "
                   & To_String (Block.Node.Value_Or
                     (Taste_Node'(Name => US ("(none)"), others => <>)).Name));
      end loop;

      for Thread of CV.Threads loop
         Put_Line (Output, "Thread : " & To_String (Thread.Name));
         Put_Line (Output, " |_ Port : " & To_String (Thread.Entry_Port_Name));
         Put_Line (Output, " |_ Protected Block : "
                   & To_String (Thread.Protected_Block_Name));
         Put_Line (Output, " |_ Node : "
                   & To_String (Thread.Node.Value_Or
                     (Taste_Node'(Name => US ("(none)"), others => <>)).Name));
         for Out_Port of Thread.Output_Ports loop
            Put_Line (Output, " |_ Output port remote thread : "
                      & To_String (Out_Port.Remote_Thread));
            Put_Line (Output, " |_ Output port remote PI : "
                      & To_String (Out_Port.Remote_PI));
         end loop;
      end loop;
   end Debug_Dump;

   function Concurrency_View_Template (CV : Taste_Concurrency_View)
                                       return CV_As_Template is
      Result : CV_As_Template;
      pragma Unreferenced (CV);
   begin
      return Result;
   end Concurrency_View_Template;

end TASTE.Concurrency_View;
