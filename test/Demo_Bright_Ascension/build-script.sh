#!/bin/bash

# This script will build your TASTE system.

# You should check it before running it to make it fit with your context:
# 1) You may need to fix some paths and filenames (path to interface/deployment views)
# 2) You may need to specify additional paths for the compiler to find .h file
#    (e.g. "export C_INCLUDE_PATH=/usr/include/xenomai/analogy/:$C_INCLUDE_PATH")
# 3) You may need to link with pre-built libraries, using the -l option
#    (e.g. -l /usr/lib/libanalogy.a,/usr/lib/librtdm.a)
# 4) You may need to change the runtime (add -p flag to select PolyORB-HI-C)
# etc.

# Note: TASTE will not overwrite your changes - if you need to update some parts
#       you will have to merge the changes with the newly-created file.

mkdir -p .cache
export PROJECT_CACHE=$HOME/.taste_AST_cache

if [ -z "$DEPLOYMENTVIEW" ]
then
    DEPLOYMENTVIEW=DeploymentView.aadl
fi

SKELS="./"

cd "$SKELS"
rm -f space_link_rx.zip
zip space_link_rx space_link_rx/*
rm -f space_link_tx.zip
zip space_link_tx space_link_tx/*
rm -f alert_service_adapter.zip
zip alert_service_adapter alert_service_adapter/*
rm -f aggregation_service_adapter.zip
zip aggregation_service_adapter aggregation_service_adapter/*
rm -f action_service_adapter.zip
zip action_service_adapter action_service_adapter/*
rm -f mode_control_service_adapter.zip
zip mode_control_service_adapter mode_control_service_adapter/*
rm -f parameter_service_adapter.zip
zip parameter_service_adapter parameter_service_adapter/*
rm -f check_service_adapter.zip
zip check_service_adapter check_service_adapter/*
rm -f pus_housekeeping_service_protocol_handler.zip
zip pus_housekeeping_service_protocol_handler pus_housekeeping_service_protocol_handler/*
rm -f pus_parameter_service_handler.zip
zip pus_parameter_service_handler pus_parameter_service_handler/*
rm -f pus_custom_service_protocol_handler.zip
zip pus_custom_service_protocol_handler pus_custom_service_protocol_handler/*
rm -f alert_service_dispatch.zip
zip alert_service_dispatch alert_service_dispatch/*
rm -f aggregation_service_dispatch.zip
zip aggregation_service_dispatch aggregation_service_dispatch/*
rm -f check_service_dispatch.zip
zip check_service_dispatch check_service_dispatch/*
rm -f action_service_dispatch.zip
zip action_service_dispatch action_service_dispatch/*
rm -f mode_control_service_dispatch.zip
zip mode_control_service_dispatch mode_control_service_dispatch/*
rm -f parameter_service_dispatch.zip
zip parameter_service_dispatch parameter_service_dispatch/*
rm -f pus_protocol_handling.zip
zip pus_protocol_handling pus_protocol_handling/*
rm -f pus_spp_handling.zip
zip pus_spp_handling pus_spp_handling/*
rm -f mode_manager.zip
zip mode_manager mode_manager/*
rm -f mode_manager_container.zip
zip mode_manager_container mode_manager_container/*
rm -f virtual_gyro_device.zip
zip virtual_gyro_device virtual_gyro_device/*
rm -f virtual_gyro_container.zip
zip virtual_gyro_container virtual_gyro_container/*
rm -f spp_packet_service.zip
zip spp_packet_service spp_packet_service/*
rm -f space_packet_routing.zip
zip space_packet_routing space_packet_routing/*
rm -f thermal_manager.zip
zip thermal_manager thermal_manager/*
rm -f mal_dispatch.zip
zip mal_dispatch mal_dispatch/*
rm -f thermal_manager_container.zip
zip thermal_manager_container thermal_manager_container/*
rm -f mal_space_packet_binding.zip
zip mal_space_packet_binding mal_space_packet_binding/*
rm -f pus_service_dispatch.zip
zip pus_service_dispatch pus_service_dispatch/*
rm -f aggregation_service_provider.zip
zip aggregation_service_provider aggregation_service_provider/*
rm -f check_service_provider.zip
zip check_service_provider check_service_provider/*
rm -f gyro_device_access.zip
zip gyro_device_access gyro_device_access/*
cd "$OLDPWD"

[ ! -z "$CLEANUP" ] && rm -rf binary

if [ -f ConcurrencyView.pro ]
then
    ORCHESTRATOR_OPTIONS+=" -w ConcurrencyView.pro "
fi

if [ ! -z "$USE_POHIC" ]
then
    OUTPUTDIR=binary.c
    ORCHESTRATOR_OPTIONS+=" -p "
elif [ ! -z "$USE_POHIADA" ]
then
    OUTPUTDIR=binary.ada
else
    OUTPUTDIR=binary
fi
assert-builder-ocarina.py \
	--fast \
	--debug \
	--aadlv2 \
	--keep-case \
	--interfaceView InterfaceView.aadl \
	--deploymentView "$DEPLOYMENTVIEW" \
	-o "$OUTPUTDIR" \
	--subC space_link_rx:"$SKELS"/space_link_rx.zip \
	--subC space_link_tx:"$SKELS"/space_link_tx.zip \
	--subC alert_service_adapter:"$SKELS"/alert_service_adapter.zip \
	--subC aggregation_service_adapter:"$SKELS"/aggregation_service_adapter.zip \
	--subC action_service_adapter:"$SKELS"/action_service_adapter.zip \
	--subC mode_control_service_adapter:"$SKELS"/mode_control_service_adapter.zip \
	--subC parameter_service_adapter:"$SKELS"/parameter_service_adapter.zip \
	--subC check_service_adapter:"$SKELS"/check_service_adapter.zip \
	--subC pus_housekeeping_service_protocol_handler:"$SKELS"/pus_housekeeping_service_protocol_handler.zip \
	--subC pus_parameter_service_handler:"$SKELS"/pus_parameter_service_handler.zip \
	--subC pus_custom_service_protocol_handler:"$SKELS"/pus_custom_service_protocol_handler.zip \
	--subC alert_service_dispatch:"$SKELS"/alert_service_dispatch.zip \
	--subC aggregation_service_dispatch:"$SKELS"/aggregation_service_dispatch.zip \
	--subC check_service_dispatch:"$SKELS"/check_service_dispatch.zip \
	--subC action_service_dispatch:"$SKELS"/action_service_dispatch.zip \
	--subC mode_control_service_dispatch:"$SKELS"/mode_control_service_dispatch.zip \
	--subC parameter_service_dispatch:"$SKELS"/parameter_service_dispatch.zip \
	--subC pus_protocol_handling:"$SKELS"/pus_protocol_handling.zip \
	--subC pus_spp_handling:"$SKELS"/pus_spp_handling.zip \
	--subC mode_manager:"$SKELS"/mode_manager.zip \
	--subC mode_manager_container:"$SKELS"/mode_manager_container.zip \
	--subC virtual_gyro_device:"$SKELS"/virtual_gyro_device.zip \
	--subC virtual_gyro_container:"$SKELS"/virtual_gyro_container.zip \
	--subC spp_packet_service:"$SKELS"/spp_packet_service.zip \
	--subC space_packet_routing:"$SKELS"/space_packet_routing.zip \
	--subC thermal_manager:"$SKELS"/thermal_manager.zip \
	--subC mal_dispatch:"$SKELS"/mal_dispatch.zip \
	--subC thermal_manager_container:"$SKELS"/thermal_manager_container.zip \
	--subC mal_space_packet_binding:"$SKELS"/mal_space_packet_binding.zip \
	--subC pus_service_dispatch:"$SKELS"/pus_service_dispatch.zip \
	--subC aggregation_service_provider:"$SKELS"/aggregation_service_provider.zip \
	--subC check_service_provider:"$SKELS"/check_service_provider.zip \
	--subC gyro_device_access:"$SKELS"/gyro_device_access.zip \
	$ORCHESTRATOR_OPTIONS
