# MAKEFILE_PATH   := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_PATH   := $(lastword $(MAKEFILE_LIST))
OUTDIR          := $(dir $(MAKEFILE_PATH))
ASN1_FILES      := /home/taste/e2es/DataView.asn /home/taste/tool-inst/share/taste-types/taste-types.asn
CP_FILES        := ../work/geometrymodule_implementation/Ada/Context-geometrymodule-implementation.asn ../work/observation_timeline_implementation/C/Context-observation-timeline-implementation.asn ../work/scene_creation_implementation/C/Context-scene-creation-implementation.asn      # Context parameters
DATAVIEW_PATH   := ${OUTDIR}/dataview
DATAVIEW_UNIQ   := ${DATAVIEW_PATH}/dataview-uniq.asn
DATAVIEW_ACN    := ${DATAVIEW_PATH}/dataview-uniq.acn
DATAVIEW_AADLV1 := ${DATAVIEW_PATH}/dataview_aadlv1.aadl
DATAVIEW_AADLV2 := ${DATAVIEW_PATH}/dataview_aadlv2.aadl

# Project cache folder is used to speed up all ASN.1-related processing
export PROJECT_CACHE=${HOME}/.taste_AST_cache

all:	build-default


# Generate the language-specific data view needed before editing user code
dataview:	dataview/C/built dataview/Ada/built

# Generate the complete dataview, including Python bindings if there is a GUI
${DATAVIEW_PATH}/built:	dataview dataview/Python/built
	touch $@

# Build based on the deployment view
build-default:	aadl2glueC build/system_config.h ${DATAVIEW_PATH}/built build/deploymentview_final/Makefile
	$(MAKE) -j -C build -f Makefile.taste

# Force build with RTEMS/Leon, even if deployment view does not specify it
build-rtems-ada:	aadl2glueC build/system_config.h ${DATAVIEW_PATH}/built build/deploymentview_final/Makefile
	$(MAKE) -j -C build -f Makefile.taste rtems_ada

# Force build with AIR (TSP), even if deployment view does not specify it
air:	aadl2glueC build/system_config.h ${DATAVIEW_PATH}/built build/deploymentview_final/Makefile
	$(MAKE) -j -C build -f Makefile.taste air

# Rule to invoke Ocarina (generation of POHI middleware code)
build/deploymentview_final/Makefile:	build/main.aadl ${DATAVIEW_AADLV2} ../ConcurrencyView_Properties.aadl
	taste-patch-cv-properties.py build/system.aadl ../ConcurrencyView_Properties.aadl
	cd build && ocarina -x main.aadl

# Optionally hold thread priorities, offset, stack size. Create if not present
../ConcurrencyView_Properties.aadl:
	touch $@

# Optionally manage SQL Database (run taste-create-database to enable)
sql_db/DV.py:
	mkdir -p sql_db && touch $@

# Create dataview-uniq.asn by concatenating all asn1 input files
${DATAVIEW_UNIQ}:	${ASN1_FILES}
	mkdir -p ${PROJECT_CACHE} && mkdir -p ${DATAVIEW_PATH}
	sed -e '$$s/$$/\n/' -s $^ > $@

# Create dataview-uniq.acn by concatenating all input files
${DATAVIEW_ACN}:	/home/taste/e2es/DataView.acn
	mkdir -p ${DATAVIEW_PATH}
	sed -e '$$s/$$/\n/' -s $^ > $@

# system_config.h is used to filter out non-needed ASN.1 encoder/decoders
build/system_config.h:	$(wildcard */*/wrappers/*_system_config.h)
	cat $^ > $@

#  Call DMT/aadl2glueC to generate glue code from the mini-cv.aadl files
aadl2glueC:	console/GUI/wrappers/aadl2glueC_built geometrymodule_implementation/Ada/wrappers/aadl2glueC_built geometrymodule_interface/SDL/wrappers/aadl2glueC_built observation_timeline_implementation/C/wrappers/aadl2glueC_built observation_timeline_interface/SDL/wrappers/aadl2glueC_built scene_creation_implementation/C/wrappers/aadl2glueC_built scene_creation_interface/SDL/wrappers/aadl2glueC_built simulation_manager/SDL/wrappers/aadl2glueC_built

# Build dataview.aadl in AADLv1 format, used by DMT to generate glue code
${DATAVIEW_AADLV1}: ${DATAVIEW_UNIQ}
	asn2aadlPlus  $< $@

# Build dataview.aadl in AADLv2 format, used by Ocarina to generate glue code
${DATAVIEW_AADLV2}: ${DATAVIEW_UNIQ}
	asn2aadlPlus --aadlv2  $< $@

console/GUI/wrappers/aadl2glueC_built: console/GUI/wrappers/console_mini_cv.aadl ${DATAVIEW_AADLV1}
	aadl2glueC -o $(dir $@) $^
	touch $@

geometrymodule_implementation/Ada/wrappers/aadl2glueC_built: geometrymodule_implementation/Ada/wrappers/geometrymodule_implementation_mini_cv.aadl ${DATAVIEW_AADLV1}
	aadl2glueC -o $(dir $@) $^
	touch $@

geometrymodule_interface/SDL/wrappers/aadl2glueC_built: geometrymodule_interface/SDL/wrappers/geometrymodule_interface_mini_cv.aadl ${DATAVIEW_AADLV1}
	aadl2glueC -o $(dir $@) $^
	touch $@

observation_timeline_implementation/C/wrappers/aadl2glueC_built: observation_timeline_implementation/C/wrappers/observation_timeline_implementation_mini_cv.aadl ${DATAVIEW_AADLV1}
	aadl2glueC -o $(dir $@) $^
	touch $@

observation_timeline_interface/SDL/wrappers/aadl2glueC_built: observation_timeline_interface/SDL/wrappers/observation_timeline_interface_mini_cv.aadl ${DATAVIEW_AADLV1}
	aadl2glueC -o $(dir $@) $^
	touch $@

scene_creation_implementation/C/wrappers/aadl2glueC_built: scene_creation_implementation/C/wrappers/scene_creation_implementation_mini_cv.aadl ${DATAVIEW_AADLV1}
	aadl2glueC -o $(dir $@) $^
	touch $@

scene_creation_interface/SDL/wrappers/aadl2glueC_built: scene_creation_interface/SDL/wrappers/scene_creation_interface_mini_cv.aadl ${DATAVIEW_AADLV1}
	aadl2glueC -o $(dir $@) $^
	touch $@

simulation_manager/SDL/wrappers/aadl2glueC_built: simulation_manager/SDL/wrappers/simulation_manager_mini_cv.aadl ${DATAVIEW_AADLV1}
	aadl2glueC -o $(dir $@) $^
	touch $@


# Compile the ASN.1 models in C
dataview/C/built: ${DATAVIEW_UNIQ} ${DATAVIEW_ACN} ${CP_FILES}
	mkdir -p $(dir $@)
	# asn2dataModel does not take the ACN files, and only calls asn1.exe
	# asn2dataModel -o $(dir $@) -toC ${DATAVIEW_UNIQ} ${DATAVIEW_ACN}
	asn1.exe -typePrefix asn1Scc -equal -fp AUTO -o $(dir $@) -c -uPER -ACN $^
	cp $(shell taste-config --prefix)/share/AutoGUI/debug_messages.? dataview/C
	cp $(shell taste-config --prefix)/share/AutoGUI/timeInMS.? dataview/C
	cd dataview/C && msgPrinter ../dataview-uniq.asn
	cd dataview/C && msgPrinterASN1  ../dataview-uniq.asn
	touch $@

# Compile the ASN.1 models in Python for the autogenerated GUIs
dataview/Python/built:	dataview/C/built console/GUI/wrappers/aadl2glueC_built sql_db/DV.py
	mkdir -p $(dir $@)
	asn2dataModel -o $(dir $@) -toPython ${DATAVIEW_UNIQ}
	$(MAKE) -C dataview/Python -f Makefile.python
	cp dataview/Python/* console/GUI/wrappers/python
	cp dataview/C/timeInMS.[ch] dataview/C/debug_messages.c console/GUI/wrappers/python
	cd console/GUI/wrappers/python && \
	   gcc -g -fPIC -c `python-config --cflags`  gui_api.c ../../src/queue_manager.c timeInMS.c debug_messages.c -I. -I../../src && \
	   gcc -g -shared -o PythonAccess.so gui_api.o queue_manager.o timeInMS.o debug_messages.o `python-config --ldflags` -lrt
	mkdir -p binaries/console_GUI
	cp -f console/GUI/wrappers/python/* binaries/console_GUI
	cp -f console/GUI/wrappers/*.py binaries/console_GUI
	cp -f console/GUI/wrappers/*.ui binaries/console_GUI
	if [ -f sql_db/db.info ]; then cd binaries/console_GUI && ln -fs ../../sql_db; fi
	# User can edit at will the customisable user widgets python module:
	cp -u $(shell taste-config --prefix)/share/AutoGUI/UserWidgets.py binaries/console_GUI
        #  Interface view must be placed in the gui folder to allow replaying MSCs
	cp -u ../InterfaceView.aadl binaries/console_GUI
	touch $@

dataview/Ada/built: ${DATAVIEW_UNIQ} ${CP_FILES}
	mkdir -p $(dir $@)
	asn2dataModel -o $(dir $@) -toAda $^
	touch $@
	cd dataview/Ada && rm -f gnat.cfg GPS_project.gpr IgnoredExaminerWarnings.wrn runSpark.sh
        # Copy the dataview to SDL function GeometryModule_Interface (no context parameters)
	cp -u ${DATAVIEW_UNIQ} geometrymodule_interface/SDL/src
        # Copy the dataview to SDL function Observation_Timeline_Interface (no context parameters)
	cp -u ${DATAVIEW_UNIQ} observation_timeline_interface/SDL/src
        # Copy the dataview to SDL function Scene_Creation_Interface (no context parameters)
	cp -u ${DATAVIEW_UNIQ} scene_creation_interface/SDL/src
        # Copy the dataview to SDL function Simulation_Manager (no context parameters)
	cp -u ${DATAVIEW_UNIQ} simulation_manager/SDL/src

function-types-linux:
	$(MAKE) -j -C functiontype1/CPP compile-linux

function-instances-linux:	function-types-linux
	$(MAKE) -C console/GUI -j compile-linux
	$(MAKE) -C geometrymodule_implementation/Ada -j compile-linux
	$(MAKE) -C geometrymodule_interface/SDL -j compile-linux
	$(MAKE) -C observation_timeline_implementation/C -j compile-linux
	$(MAKE) -C observation_timeline_interface/SDL -j compile-linux
	$(MAKE) -C scene_creation_implementation/C -j compile-linux
	$(MAKE) -C scene_creation_interface/SDL -j compile-linux
	$(MAKE) -C simulation_manager/SDL -j compile-linux

compile-all-linux:	dataviews function-instances-linux

clean:
	rm -rf binaries dataview
	$(MAKE) -C build -f Makefile.taste clean

.PHONY: clean compile-all-linux function-instances-linux function-types-linux build-default dataview build-rtems-ada dataview
