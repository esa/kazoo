KAZOO=../../kazoo
# Add compiler and linker flags
export USER_CFLAGS=
export USER_LDFLAGS=
# you can add folders with source code you want to compile
export EXTERNAL_SOURCE_PATH=

all: c ada rtems

ada:
	rm -rf output.ada
	$(KAZOO) --gw -o output.ada --glue --debug
	cp simple_c_function/*.c output.ada/simple_c_function/C/src
	$(MAKE) -C output.ada

c: # Polyorb_HI_C output
	rm -rf work
	$(KAZOO) -p --gw --glue -o work
	cp simple_c_function/*.c work/simple_c_function/C/src
	$(MAKE) -C work

rtems:
	rm -f output.rtems
	$(KAZOO) -p --gw --glue -o output.rtems
	cp simple_c_function/*.c output.rtems/simple_c_function/C/src
	$(MAKE) -C output.rtems build-rtems-ada

gdb-ada: clean
	gdb --args $(KAZOO) --gw --glue --debug -o output.gdb

gdb-c: clean
	gdb --args $(KAZOO) -p --gw --glue --debug -o output.gdb

clean-ada:
	rm -rf output.ada

clean-c:
	rm -rf work

clean-rtems:
	rm -rf output.rtems

skeletons:
	$(KAZOO) --gw -o work
	$(MAKE)  -C work dataview

clean-skeletons: clean-c

clean: clean-ada clean-c clean-rtems

.PHONY: clean clean-ada clean-c clean-rtems kazoo-ada kazoo-c gdb-ada gdb-c c ada skeletons-c clean-skeletons
