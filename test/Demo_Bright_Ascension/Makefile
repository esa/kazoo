KAZOO=../../kazoo

all: c

c: test-parse-c # Polyorb_HI_C output
	cp action_service_adapter/action_service_adapter.c work/action_service_adapter/C/src
	cp action_service_dispatch/action_service_dispatch.c work/action_service_dispatch/C/src
	cp aggregation_service_adapter/aggregation_service_adapter.c work/aggregation_service_adapter/C/src
	cp aggregation_service_dispatch/aggregation_service_dispatch.c work/aggregation_service_dispatch/C/src
	cp aggregation_service_provider/aggregation_service_provider.c work/aggregation_service_provider/C/src
	cp alert_service_adapter/alert_service_adapter.c work/alert_service_adapter/C/src
	cp alert_service_dispatch/alert_service_dispatch.c work/alert_service_dispatch/C/src
	cp check_service_adapter/check_service_adapter.c work/check_service_adapter/C/src
	cp check_service_dispatch/check_service_dispatch.c work/check_service_dispatch/C/src
	cp check_service_provider/check_service_provider.c work/check_service_provider/C/src
	#cp gyro_device/gyro_device.c work/gyro_device/C/src
	cp gyro_device_access/gyro_device_access.c work/gyro_device_access/C/src
	#cp gyro_device_accesss/gyro_device_accesss.c work/gyro_device_accesss/C/src
	cp mal_dispatch/mal_dispatch.c work/mal_dispatch/C/src
	cp mal_space_packet_binding/mal_space_packet_binding.c work/mal_space_packet_binding/C/src
	cp mode_control_service_adapter/mode_control_service_adapter.c work/mode_control_service_adapter/C/src
	cp mode_control_service_dispatch/mode_control_service_dispatch.c work/mode_control_service_dispatch/C/src
	cp mode_manager/mode_manager.c work/mode_manager/C/src
	cp mode_manager_container/mode_manager_container.c work/mode_manager_container/C/src
	cp parameter_service_adapter/parameter_service_adapter.c work/parameter_service_adapter/C/src
	cp parameter_service_dispatch/parameter_service_dispatch.c work/parameter_service_dispatch/C/src
	cp pus_custom_service_protocol_handler/pus_custom_service_protocol_handler.c work/pus_custom_service_protocol_handler/C/src
	cp pus_housekeeping_service_protocol_handler/pus_housekeeping_service_protocol_handler.c work/pus_housekeeping_service_protocol_handler/C/src
	cp pus_parameter_service_handler/pus_parameter_service_handler.c work/pus_parameter_service_handler/C/src
	cp pus_protocol_handling/pus_protocol_handling.c work/pus_protocol_handling/C/src
	cp pus_service_dispatch/pus_service_dispatch.c work/pus_service_dispatch/C/src
	#cp pus_spp_handling/pus_spp_handling.c work/pus_spp_handling/C/src
	#cp space_link_rx/space_link_rx.c work/space_link_rx/C/src
	#cp space_link_tx/space_link_tx.c work/space_link_tx/C/src
	#cp space_packet_routing/space_packet_routing.c work/space_packet_routing/C/src
	#cp spp_packet_service/spp_packet_service.c work/spp_packet_service/C/src
	cp thermal_manager/thermal_manager.c work/thermal_manager/C/src
	cp thermal_manager_container/thermal_manager_container.c work/thermal_manager_container/C/src
	cp virtual_gyro_container/virtual_gyro_container.c work/virtual_gyro_container/C/src
	cp virtual_gyro_device/virtual_gyro_device.c work/virtual_gyro_device/C/src
	$(MAKE) -C work

test-parse-c: clean-c
	$(KAZOO) -p --gw \
	         -o work \
	         --glue -g
buildsupport_pohic:
	buildsupport -o output.buildsupport.pohic -p --aadlv2 --glue -i InterfaceView.aadl -c DeploymentView.aadl -d DataView.aadl ../common/ocarina_components.aadl ../common/TASTE_IV_Properties.aadl ../common/TASTE_DV_Properties.aadl

buildsupport_pohiada:
	buildsupport -o output.buildsupport.ada --aadlv2 --glue -i InterfaceView.aadl -c DeploymentView.aadl -d DataView.aadl ../common/ocarina_components.aadl ../common/TASTE_IV_Properties.aadl ../common/TASTE_DV_Properties.aadl

gdb: clean
	gdb --args $(KAZOO) --gw \
	               -o work \
	               --glue \
		       --debug

clean-c:
	rm -rf work

skeletons:
	$(KAZOO) -p --gw --glue -o work && make -C work dataview

clean-skeletons:
	rm -rf work

clean:  clean-c clean-skeletons

.PHONY: clean clean-c gdb test-parse-c buildsupport_pohic buildsupport_pohiada c skeletons clean-skeletons
