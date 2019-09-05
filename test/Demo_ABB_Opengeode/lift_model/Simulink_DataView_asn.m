% Values for UpDown:
UpDown_value_up = 1;
UpDown_value_down = 0;
UpDown = Simulink.AliasType;
UpDown.BaseType = 'int32';
UpDown.Description = 'values of ENUMERATED UpDown';


Flag = Simulink.AliasType;
Flag.BaseType = 'boolean';
Flag.Description = 'A simple BOOLEAN';

% Values for Floors:
Floors_value_floor_0 = 10;
Floors_value_floor_1 = 20;
Floors_value_floor_2 = 30;
Floors_value_floor_3 = 40;
Floors_value_floor_4 = 50;
Floors_value_floor_5 = 60;
Floors = Simulink.AliasType;
Floors.BaseType = 'int32';
Floors.Description = 'values of ENUMERATED Floors';


Cabin_button_elem01=Simulink.BusElement;
Cabin_button_elem01.name='choiceIdx';
Cabin_button_elem01.DataType='uint8';
Cabin_button_elem01.dimensions=1;

Cabin_button_elem02=Simulink.BusElement;
Cabin_button_elem02.name='emergency_stop';
Cabin_button_elem02.DataType='boolean';
Cabin_button_elem02.dimensions=1;

Cabin_button_elem03=Simulink.BusElement;
Cabin_button_elem03.name='floor';
Cabin_button_elem03.DataType='int32';
Cabin_button_elem03.dimensions=1;

Cabin_button = Simulink.Bus;
Cabin_button.Elements = [Cabin_button_elem01 Cabin_button_elem02 Cabin_button_elem03 ];

% Values for OpenClose:
OpenClose_value_door_open = 1;
OpenClose_value_door_close = 0;
OpenClose = Simulink.AliasType;
OpenClose.BaseType = 'int32';
OpenClose.Description = 'values of ENUMERATED OpenClose';


% Values for OnOff:
OnOff_value_on = 1;
OnOff_value_off = 0;
OnOff = Simulink.AliasType;
OnOff.BaseType = 'int32';
OnOff.Description = 'values of ENUMERATED OnOff';


Lift_control_elem01=Simulink.BusElement;
Lift_control_elem01.name='direction';
Lift_control_elem01.DataType='int32';
Lift_control_elem01.dimensions=1;

Lift_control_elem02=Simulink.BusElement;
Lift_control_elem02.name='motor';
Lift_control_elem02.DataType='int32';
Lift_control_elem02.dimensions=1;

Lift_control_elem03=Simulink.BusElement;
Lift_control_elem03.name='brake';
Lift_control_elem03.DataType='int32';
Lift_control_elem03.dimensions=1;

Lift_control_elem04=Simulink.BusElement;
Lift_control_elem04.name='door';
Lift_control_elem04.DataType='int32';
Lift_control_elem04.dimensions=1;

Lift_control = Simulink.Bus;
Lift_control.Elements = [Lift_control_elem01 Lift_control_elem02 Lift_control_elem03 Lift_control_elem04 ];

Start_condition_elem01=Simulink.BusElement;
Start_condition_elem01.name='choiceIdx';
Start_condition_elem01.DataType='uint8';
Start_condition_elem01.dimensions=1;

Start_condition_elem02=Simulink.BusElement;
Start_condition_elem02.name='forever';
Start_condition_elem02.DataType='boolean';
Start_condition_elem02.dimensions=1;

Start_condition_elem03=Simulink.BusElement;
Start_condition_elem03.name='nb_of_cycle';
Start_condition_elem03.DataType='uint8';
Start_condition_elem03.dimensions=1;

Start_condition = Simulink.Bus;
Start_condition.Elements = [Start_condition_elem01 Start_condition_elem02 Start_condition_elem03 ];

Position = Simulink.AliasType;
Position.BaseType = 'double';
Position.Description = 'range is [0.0, 100.0]';

Lift_sensor_elem01=Simulink.BusElement;
Lift_sensor_elem01.name='door_open';
Lift_sensor_elem01.DataType='boolean';
Lift_sensor_elem01.dimensions=1;

Lift_sensor_elem02=Simulink.BusElement;
Lift_sensor_elem02.name='door_closed';
Lift_sensor_elem02.DataType='boolean';
Lift_sensor_elem02.dimensions=1;

Lift_sensor_elem03=Simulink.BusElement;
Lift_sensor_elem03.name='floor_detected';
Lift_sensor_elem03.DataType='boolean';
Lift_sensor_elem03.dimensions=1;

Lift_sensor_elem04=Simulink.BusElement;
Lift_sensor_elem04.name='pos_x';
Lift_sensor_elem04.DataType='double';
Lift_sensor_elem04.dimensions=1;

Lift_sensor = Simulink.Bus;
Lift_sensor.Elements = [Lift_sensor_elem01 Lift_sensor_elem02 Lift_sensor_elem03 Lift_sensor_elem04 ];

Floor_button_elem01=Simulink.BusElement;
Floor_button_elem01.name='floor';
Floor_button_elem01.DataType='int32';
Floor_button_elem01.dimensions=1;

Floor_button_elem02=Simulink.BusElement;
Floor_button_elem02.name='direction';
Floor_button_elem02.DataType='int32';
Floor_button_elem02.dimensions=1;

Floor_button = Simulink.Bus;
Floor_button.Elements = [Floor_button_elem01 Floor_button_elem02 ];

