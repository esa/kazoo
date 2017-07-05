--  ************************ taste aadl parser ****************************  --
--  (c) 2008-2017 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file
--  Define a generic Option type
generic
   type T is private;
package Option_Type is
   type Option is tagged private;
   function Just (I : T) return Option;
   function Nothing return Option;
   --  function Just (O : Option) return T;
   --  function Value (O : Option) return T renames Just;
   function Value_Or (O : Option; Default : T) return T;
   function Has_Value (O : Option) return Boolean;

private

   type Option is tagged
      record
          Present : Boolean := False;
          Value   : T;
      end record;

   function Just (I : T) return Option is
       (Present => True, Value => I);

   function Nothing return Option is
       (Present => False, others => <>);

   --  function Just (O : Option) return T is (O.Value);

   function Value_Or (O : Option; Default : T) return T is
       (if O.Present then O.Value else Default);

   function Has_Value (O : Option) return Boolean is (O.Present);
end Option_Type;
