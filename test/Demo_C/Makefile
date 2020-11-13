KAZOO=../../kazoo
# Add compiler and linker flags
export USER_CFLAGS=
# Global: 
export USER_LDFLAGS=
# Per partition:
export DEMO_C_USER_LDFLAGS=
# you can add folders with source code you want to compile
# Global:
export EXTERNAL_SOURCE_PATH=
# Per partition:
export DEMO_C_EXTERNAL_SOURCE_PATH=

all: c ada rtems c-debug-coverage

ada:
	rm -rf output.ada
	$(KAZOO) -c DeploymentView_Native.aadl --gw -o output.ada --glue --debug
	cp simple_c_function/*.c output.ada/simple_c_function/C/src
	$(MAKE) -C output.ada

c: # Polyorb_HI_C output in Release mode
	rm -rf work
	$(KAZOO) -c DeploymentView_Native.aadl -p --gw --glue -o work
	cp simple_c_function/*.c work/simple_c_function/C/src
	$(MAKE) -C work
	./regression.py

c-debug-coverage: # Polyorb_HI_C output in Debug with Coverage enabled
	rm -rf work-debug
	$(KAZOO) -c DeploymentView_Coverage.aadl -p -g --gw --glue -o work-debug
	cp simple_c_function/*.c work-debug/simple_c_function/C/src
	$(MAKE) -C work-debug

simu:
	rm -rf work
	$(KAZOO) -t SIMU -c DeploymentView_Native.aadl -p -g --gw --glue -o work
	cp simple_c_function/*.c work/simple_c_function/C/src
	$(MAKE) -C work 

rtems:
	rm -rf output.rtems
	$(KAZOO) -c DeploymentView_Leon3.aadl -p --gw --glue -o output.rtems
	cp simple_c_function/*.c output.rtems/simple_c_function/C/src
	$(MAKE) -C output.rtems build-rtems-ada

gdb-ada: clean
	gdb --args $(KAZOO) --gw --glue --debug -o output.gdb

gdb-c: clean
	gdb --args $(KAZOO) -p -c DeploymentView_Native.aadl --gw --glue --debug -o output.gdb

clean-ada:
	rm -rf output.ada

clean-c:
	rm -rf work work-debug

clean-rtems:
	rm -rf output.rtems

skeletons:
	$(KAZOO) --gw -o work
	$(MAKE)  -C work dataview

clean-skeletons: clean-c

clean: clean-ada clean-c clean-rtems

.PHONY: clean clean-ada clean-c clean-rtems kazoo-ada kazoo-c gdb-ada gdb-c c ada skeletons-c clean-skeletons
