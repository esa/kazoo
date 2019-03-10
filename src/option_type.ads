--  ************************ taste aadl parser ****************************  --
--  (c) 2008-2019 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file
--  Define a generic Option type
generic
   type T is private;
package Option_Type is
   type Option is tagged private;
   function Just        (I : T)                   return Option;
   function Unsafe_Just (O : Option)              return T;
   function Value_Or    (O : Option; Default : T) return T;
   function Has_Value   (O : Option)              return Boolean;
   Nothing       : constant Option;
   Invalid_Value : constant Option;

private

   type Option is tagged
      record
         Present : Boolean := False;
         Valid   : Boolean := True;
         Value   : T;
      end record;

   function Just (I : T) return Option is (Present => True,
                                           Valid   => True,
                                           Value   => I);

   function Unsafe_Just (O : Option) return T is (O.Value);

   function Value_Or (O : Option; Default : T) return T is
       (if O.Present and O.Valid then O.Value else Default);

   function Has_Value (O : Option) return Boolean is (O.Present and O.Valid);
   Nothing       : constant Option := (Present => False, others => <>);
   Invalid_Value : constant Option := (Valid   => False, others => <>);
end Option_Type;
