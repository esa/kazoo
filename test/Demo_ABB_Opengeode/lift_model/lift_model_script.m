run Simulink_DataView_asn;

if (exist('Operate_lift') == 4),
	simulink('open');
	load_system('Operate_lift');
	open_system('Operate_lift');
	inportHan = find_system('Operate_lift','FindAll','on', 'SearchDepth', 1, 'BlockType','Inport');
	outportHan = find_system('Operate_lift','FindAll','on', 'SearchDepth', 1, 'BlockType','Outport');
% ---------------------------------------------------------------------------------
% start by removing the Bus Selectors / then lines / finally ports 
% ---------------------------------------------------------------------------------
% get the handles of all the lines connected to inports 
for i=1:length(inportHan)
	line_structsIn(i)=get_param(inportHan(i),'LineHandles'); % get the structures
	inLinesHan(i)=line_structsIn(i).Outport;	% get the line connected to the block's Outport
	if (inLinesHan(i) ~= -1) % if exists
		dstBlock = get_param(inLinesHan(i),'DstBlockHandle'); % get the destination block's handle
		if (strcmp(get_param(dstBlock,'BlockType'),'BusSelector'))
			blockLineStructs = get_param(dstBlock,'LineHandles'); % get the line connected structures
			blockLineHandles = blockLineStructs.Outport; % get the line handlers connected to the bus's outports
			for j=1:length(blockLineHandles)
				if (blockLineHandles(j) ~= -1)
					delete(blockLineHandles(j));
				end
			end
			delete_block(dstBlock); % delete it if it is a Bus Selector Block
		end
		delete(inLinesHan(i)); % delete the respective line
	end
	delete_block(inportHan(i)); % delete the outdated inport block
end
% now remove the outports
for i=1:length(outportHan)
	line_structsOut(i)=get_param(outportHan(i),'LineHandles'); % get the structures
	outLinesHan(i)=line_structsOut(i).Inport;	% get the line connected to the block's Inport
	if (outLinesHan(i) ~= -1) % if exists
		srcBlock = get_param(outLinesHan(i),'SrcBlockHandle'); % get the source block's handle
		if (strcmp(get_param(srcBlock,'BlockType'),'BusCreator'))
			blockLineStructs = get_param(srcBlock,'LineHandles'); % get the line connected structures
			blockLineHandles = blockLineStructs.Inport; % get the line handlers connected to the bus's outports
			for j=1:length(blockLineHandles)
				if (blockLineHandles(j) ~= -1)
					delete(blockLineHandles(j));
				end
			end
			delete_block(srcBlock); % delete it if it is a Bus Creator Block
		end
		delete(outLinesHan(i)); % delete the respective line
	end
	delete_block(outportHan(i)); % delete the outdated outport block
end
else
	simulink('open');
	new_system('Operate_lift');
	open_system('Operate_lift');
end
add_block('simulink/Sources/In1','Operate_lift/lift_command');
set_param('Operate_lift/lift_command','Position',[25 25 55 39]);
set_param('Operate_lift/lift_command','UseBusObject','on');
set_param('Operate_lift/lift_command','BusObject','Lift_control');
add_block('simulink/Commonly Used Blocks/Bus Selector','Operate_lift/lift_command_Lift_control_BusSel');
add_line('Operate_lift','lift_command/1','lift_command_Lift_control_BusSel/1');
setOutputsBusSelector(Lift_control, 'Operate_lift/lift_command_Lift_control_BusSel');
set_param('Operate_lift/lift_command_Lift_control_BusSel','Position',[95 6 100 44]);
add_block('simulink/Sinks/Out1','Operate_lift/lift_sensors');
set_param('Operate_lift/lift_sensors','Position',[430 25 460 39]);
set_param('Operate_lift/lift_sensors','UseBusObject','on');
set_param('Operate_lift/lift_sensors','BusObject','Lift_sensor');
add_block('simulink/Commonly Used Blocks/Bus Creator','Operate_lift/lift_sensors_Lift_sensor_BusCre');
add_line('Operate_lift','lift_sensors_Lift_sensor_BusCre/1','lift_sensors/1');
setInputsBusCreator(Lift_sensor,'Operate_lift/lift_sensors_Lift_sensor_BusCre');
set_param('Operate_lift/lift_sensors_Lift_sensor_BusCre','BusObject','Lift_sensor');
set_param('Operate_lift/lift_sensors_Lift_sensor_BusCre','Position',[360 6 365 44]);
set_param('Operate_lift','SaveOutput','off');
set_param('Operate_lift','SignalLogging','off');
set_param('Operate_lift','SaveTime','off')
set_param('Operate_lift','Solver','FixedStepDiscrete');
set_param('Operate_lift','SystemTargetFile','ert.tlc');
set_param('Operate_lift','TemplateMakefile','ert_default_tmf');
set_param('Operate_lift', 'PostCodeGenCommand', 'packNGo(buildInfo);');
save_system('Operate_lift');
close_system('Operate_lift');
simulink('close');
