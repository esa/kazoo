T_Int32 = Simulink.AliasType;
T_Int32.BaseType = 'int32';
T_Int32.Description = 'range is (-2147483648, 2147483647)';

In_Nested_inest_a_member_data=Simulink.BusElement;
In_Nested_inest_a_member_data.name='element_data';
In_Nested_inest_a_member_data.DataType='int32';
In_Nested_inest_a_member_data.dimensions=4;

In_Nested_inest_a=Simulink.Bus;
In_Nested_inest_a.Elements = [In_Nested_inest_a_member_data ];

In_Nested_inest_b_member_data=Simulink.BusElement;
In_Nested_inest_b_member_data.name='element_data';
In_Nested_inest_b_member_data.DataType='int32';
In_Nested_inest_b_member_data.dimensions=3;

In_Nested_inest_b=Simulink.Bus;
In_Nested_inest_b.Elements = [In_Nested_inest_b_member_data ];

In_Nested_elem01=Simulink.BusElement;
In_Nested_elem01.name='inest_a';
In_Nested_elem01.DataType='In_Nested_inest_a';
In_Nested_elem01.dimensions=1;

In_Nested_elem02=Simulink.BusElement;
In_Nested_elem02.name='inest_b';
In_Nested_elem02.DataType='In_Nested_inest_b';
In_Nested_elem02.dimensions=1;

In_Nested = Simulink.Bus;
In_Nested.Elements = [In_Nested_elem01 In_Nested_elem02 ];

T_UInt32 = Simulink.AliasType;
T_UInt32.BaseType = 'uint32';
T_UInt32.Description = 'range is (0, 4294967295)';

Out_Nested_onest_a_member_data=Simulink.BusElement;
Out_Nested_onest_a_member_data.name='element_data';
Out_Nested_onest_a_member_data.DataType='int32';
Out_Nested_onest_a_member_data.dimensions=7;

Out_Nested_onest_a=Simulink.Bus;
Out_Nested_onest_a.Elements = [Out_Nested_onest_a_member_data ];

MyInteger = Simulink.AliasType;
MyInteger.BaseType = 'int32';
MyInteger.Description = 'range is (-411673351, 763937697)';

TASTE_Boolean = Simulink.AliasType;
TASTE_Boolean.BaseType = 'boolean';
TASTE_Boolean.Description = 'A simple BOOLEAN';

Seq4_member_data=Simulink.BusElement;
Seq4_member_data.name='element_data';
Seq4_member_data.DataType='int32';
Seq4_member_data.dimensions=4;

Seq4=Simulink.Bus;
Seq4.Elements = [Seq4_member_data ];

T_Int8 = Simulink.AliasType;
T_Int8.BaseType = 'int8';
T_Int8.Description = 'range is (-128, 127)';

T_UInt8 = Simulink.AliasType;
T_UInt8.BaseType = 'uint8';
T_UInt8.Description = 'range is (0, 255)';

Out_Nested_elem01=Simulink.BusElement;
Out_Nested_elem01.name='onest_a';
Out_Nested_elem01.DataType='Out_Nested_onest_a';
Out_Nested_elem01.dimensions=1;

Out_Nested = Simulink.Bus;
Out_Nested.Elements = Out_Nested_elem01 ;

Seqout_member_data=Simulink.BusElement;
Seqout_member_data.name='element_data';
Seqout_member_data.DataType='int32';
Seqout_member_data.dimensions=8;

Seqout=Simulink.Bus;
Seqout.Elements = [Seqout_member_data ];

Seq3_member_data=Simulink.BusElement;
Seq3_member_data.name='element_data';
Seq3_member_data.DataType='int32';
Seq3_member_data.dimensions=3;

Seq3=Simulink.Bus;
Seq3.Elements = [Seq3_member_data ];

T_Boolean = Simulink.AliasType;
T_Boolean.BaseType = 'boolean';
T_Boolean.Description = 'A simple BOOLEAN';

