run Simulink_DataView_asn;

inports_positions = zeros(4, 4);
bussel_positions = zeros(4, 4);
outports_positions = zeros(2, 4);
buscre_positions = zeros(2, 4);

if (exist('do_something') == 4),
	simulink('open');
	load_system('do_something');
	open_system('do_something');
	inportHan = find_system('do_something','FindAll','on', 'SearchDepth', 1, 'BlockType','Inport');
	outportHan = find_system('do_something','FindAll','on', 'SearchDepth', 1, 'BlockType','Outport');
	% ---------------------------------------------------------------------------------
	% start by removing the Bus Selectors / then lines / finally ports 
	% ---------------------------------------------------------------------------------
	% get the handles of all the lines connected to inports 
	for i=1:length(inportHan)
		inports_positions(i,:) = get_param(inportHan(i),'Position'); % remember Inport's position
		line_structsIn(i)=get_param(inportHan(i),'LineHandles'); % get the structures
		inLinesHan(i)=line_structsIn(i).Outport;	% get the line connected to the block's Outport
		if (inLinesHan(i) ~= -1) % if exists
			dstBlock = get_param(inLinesHan(i),'DstBlockHandle'); % get the destination block's handle
			if (strcmp(get_param(dstBlock,'BlockType'),'BusSelector'))
				bussel_positions(i,:) = get_param(dstBlock,'Position'); % remember Bus Selector's position
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
		outports_positions(i,:) = get_param(outportHan(i),'Position'); % remember Outport's position
		line_structsOut(i)=get_param(outportHan(i),'LineHandles'); % get the structures
		outLinesHan(i)=line_structsOut(i).Inport;	% get the line connected to the block's Inport
		if (outLinesHan(i) ~= -1) % if exists
			srcBlock = get_param(outLinesHan(i),'SrcBlockHandle'); % get the source block's handle
			if (strcmp(get_param(srcBlock,'BlockType'),'BusCreator'))
				buscre_positions(i,:) = get_param(srcBlock,'Position'); % remember Bus Creator's position
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
	new_system('do_something');
	open_system('do_something');
end
add_block('simulink/Sources/In1','do_something/inp1');
if inports_positions(1)>0
	set_param('do_something/inp1','Position', inports_positions(1,:));
else
	set_param('do_something/inp1','Position',[25 25 55 39]);
end
set_param('do_something/inp1','BusOutputAsStruct','on');
set_param('do_something/inp1','UseBusObject','on');
set_param('do_something/inp1','BusObject','Seq3');
add_block('simulink/Commonly Used Blocks/Bus Selector','do_something/inp1_Seq3_BusSel');
add_line('do_something','inp1/1','inp1_Seq3_BusSel/1');
setOutputsBusSelector(Seq3, 'do_something/inp1_Seq3_BusSel');
if bussel_positions(1)>0
	set_param('do_something/inp1_Seq3_BusSel','Position', bussel_positions(1,:));
else
	set_param('do_something/inp1_Seq3_BusSel','Position',[95 6 100 44]);
end
add_block('simulink/Sources/In1','do_something/inp2');
if inports_positions(2)>0
	set_param('do_something/inp2','Position', inports_positions(2,:));
else
	set_param('do_something/inp2','Position',[25 125 55 139]);
end
set_param('do_something/inp2','BusOutputAsStruct','on');
set_param('do_something/inp2','UseBusObject','on');
set_param('do_something/inp2','BusObject','Seq3');
add_block('simulink/Commonly Used Blocks/Bus Selector','do_something/inp2_Seq3_BusSel');
add_line('do_something','inp2/1','inp2_Seq3_BusSel/1');
setOutputsBusSelector(Seq3, 'do_something/inp2_Seq3_BusSel');
if bussel_positions(2)>0
	set_param('do_something/inp2_Seq3_BusSel','Position', bussel_positions(2,:));
else
	set_param('do_something/inp2_Seq3_BusSel','Position',[95 106 100 144]);
end
add_block('simulink/Sources/In1','do_something/inp3');
if inports_positions(3)>0
	set_param('do_something/inp3','Position', inports_positions(3,:));
else
	set_param('do_something/inp3','Position',[25 225 55 239]);
end
set_param('do_something/inp3','BusOutputAsStruct','on');
set_param('do_something/inp3','UseBusObject','on');
set_param('do_something/inp3','BusObject','Seq4');
add_block('simulink/Commonly Used Blocks/Bus Selector','do_something/inp3_Seq4_BusSel');
add_line('do_something','inp3/1','inp3_Seq4_BusSel/1');
setOutputsBusSelector(Seq4, 'do_something/inp3_Seq4_BusSel');
if bussel_positions(3)>0
	set_param('do_something/inp3_Seq4_BusSel','Position', bussel_positions(3,:));
else
	set_param('do_something/inp3_Seq4_BusSel','Position',[95 206 100 244]);
end
add_block('simulink/Sources/In1','do_something/innested');
if inports_positions(4)>0
	set_param('do_something/innested','Position', inports_positions(4,:));
else
	set_param('do_something/innested','Position',[25 325 55 339]);
end
set_param('do_something/innested','BusOutputAsStruct','on');
set_param('do_something/innested','UseBusObject','on');
set_param('do_something/innested','BusObject','In_Nested');
add_block('simulink/Commonly Used Blocks/Bus Selector','do_something/innested_In_Nested_BusSel');
add_line('do_something','innested/1','innested_In_Nested_BusSel/1');
setOutputsBusSelector(In_Nested, 'do_something/innested_In_Nested_BusSel');
if bussel_positions(4)>0
	set_param('do_something/innested_In_Nested_BusSel','Position', bussel_positions(4,:));
else
	set_param('do_something/innested_In_Nested_BusSel','Position',[95 306 100 344]);
end
add_block('simulink/Sinks/Out1','do_something/outpu');
if outports_positions(1)>0
	set_param('do_something/outpu','Position', outports_positions(1,:));
else
	set_param('do_something/outpu','Position',[430 25 460 39]);
end
set_param('do_something/outpu','UseBusObject','on');
set_param('do_something/outpu','BusObject','Seqout');
add_block('simulink/Commonly Used Blocks/Bus Creator','do_something/outpu_Seqout_BusCre');
add_line('do_something','outpu_Seqout_BusCre/1','outpu/1');
setInputsBusCreator(Seqout,'do_something/outpu_Seqout_BusCre');
set_param('do_something/outpu','UseBusObject','on');
set_param('do_something/outpu','BusOutputAsStruct','on');
set_param('do_something/outpu_Seqout_BusCre','BusObject','Seqout');
if buscre_positions(1)>0
	set_param('do_something/outpu_Seqout_BusCre','Position', buscre_positions(1,:));
else
	set_param('do_something/outpu_Seqout_BusCre','Position',[360 6 365 44]);
end
set_param('do_something/outpu_Seqout_BusCre','UseBusObject','on');
set_param('do_something/outpu_Seqout_BusCre','NonVirtualBus','on');
add_block('simulink/Sinks/Out1','do_something/outnested');
if outports_positions(2)>0
	set_param('do_something/outnested','Position', outports_positions(2,:));
else
	set_param('do_something/outnested','Position',[430 125 460 139]);
end
set_param('do_something/outnested','UseBusObject','on');
set_param('do_something/outnested','BusObject','Out_Nested');
add_block('simulink/Commonly Used Blocks/Bus Creator','do_something/outnested_Out_Nested_BusCre');
add_line('do_something','outnested_Out_Nested_BusCre/1','outnested/1');
setInputsBusCreator(Out_Nested,'do_something/outnested_Out_Nested_BusCre');
set_param('do_something/outnested','UseBusObject','on');
set_param('do_something/outnested','BusOutputAsStruct','on');
set_param('do_something/outnested_Out_Nested_BusCre','BusObject','Out_Nested');
if buscre_positions(2)>0
	set_param('do_something/outnested_Out_Nested_BusCre','Position', buscre_positions(2,:));
else
	set_param('do_something/outnested_Out_Nested_BusCre','Position',[360 106 365 144]);
end
set_param('do_something/outnested_Out_Nested_BusCre','UseBusObject','on');
set_param('do_something/outnested_Out_Nested_BusCre','NonVirtualBus','on');
set_param('do_something','SaveOutput','off');
set_param('do_something','SignalLogging','off');
set_param('do_something','SaveTime','off')
set_param('do_something','Solver','FixedStepDiscrete');
set_param('do_something','SystemTargetFile','ert.tlc');
set_param('do_something','TemplateMakefile','ert_default_tmf');
set_param('do_something', 'PostCodeGenCommand', 'packNGo(buildInfo);');
set_param('do_something','StrictBusMsg','ErrorLevel1')
save_system('do_something');
close_system('do_something');
simulink('close');
