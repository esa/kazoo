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

   --  This function translates a protected block into a template
   function To_Template (B : Protected_Block) return Block_As_Template is
      Calling_Threads : Tag;
      Result : Block_As_Template;
   begin
      for Thread of B.Calling_Threads loop
         Calling_Threads := Calling_Threads & Thread;
      end loop;

      for PI of B.Provided loop
         declare
            Basic : constant Translate_Set := PI.PI.To_Template
              & Assoc ("Protected_Block_Name", To_String (PI.Name))
              & Assoc ("Caller_Is_Local", PI.Local_Caller);
         begin
            Result.Provided.Append (Basic);
         end;
      end loop;

      for RI of B.Required loop
         Result.Required.Append (RI.To_Template);
      end loop;

      Result.Header := +Assoc  ("Name",            To_String (B.Name))
                       & Assoc ("Calling_Threads", Calling_Threads)
                       & Assoc ("Node_Name",       To_String (B.Node.Value_Or
                         (Taste_Node'(Name => US (""), others => <>)).Name));
      return Result;
   end To_Template;

   --  This function translates a thread definition into a template
   function To_Template (T : AADL_Thread) return Translate_Set is
      Remote_Thread : Vector_Tag;
      Remote_PI     : Vector_Tag;
      Ports_Matrix  : Matrix_Tag;
   begin
      for Out_Port of T.Output_Ports loop
         Remote_Thread := Remote_Thread & To_String (Out_Port.Remote_Thread);
         Remote_PI     := Remote_PI     & To_String (Out_Port.Remote_PI);
      end loop;

      Ports_Matrix := +Remote_Thread & Remote_PI;

      return Result : constant Translate_Set :=
        (+Assoc  ("Name",            To_String (T.Name))
         & Assoc ("Entry_Port_Name", To_String (T.Entry_Port_Name))
         & Assoc ("Pro_Block_Name",  To_String (T.Protected_Block_Name))
         & Assoc ("Node_Name",       To_String (T.Node.Value_Or
           (Taste_Node'(Name => US (""), others => <>)).Name))
         & Assoc ("Out_Ports",       Ports_Matrix));
   end To_Template;

   function Concurrency_View_Template (CV : Taste_Concurrency_View)
                                       return CV_As_Template
   is
      Result : CV_As_Template;
   begin
      for Thread of CV.Threads loop
         Result.Threads.Append (Thread.To_Template);
      end loop;
      for Pro of CV.Blocks loop
         Result.Blocks.Append (Pro.To_Template);
      end loop;
      return Result;
   end Concurrency_View_Template;
end TASTE.Concurrency_View;
