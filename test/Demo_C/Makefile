KAZOO=../../kazoo

all: c

ada: kazoo-ada
	cp simple_c_function/*.c output.ada/simple_c_function/C/src
	$(MAKE) -C output.ada

c: kazoo-c  # Polyorb_HI_C output
	cp simple_c_function/*.c output.c/simple_c_function/C/src
	$(MAKE) -C output.c
	$(MAKE) -C output.c build-rtems-ada

kazoo-ada: clean-ada
	$(KAZOO) --gw \
	         -o output.ada \
	         --glue \
	         --debug

kazoo-c: clean-c
	$(KAZOO) -p --gw --glue -o output.c


gdb-ada: clean
	gdb --args $(KAZOO) --gw --glue --debug -o output.gdb

gdb-c: clean
	gdb --args $(KAZOO) -p --gw --glue --debug -o output.gdb

clean-ada:
	rm -rf output.ada

clean-c:
	rm -rf output.c

skeletons-c:
	$(KAZOO) --gw -o output.c
	$(MAKE)  -C output.c dataview

clean-skeletons: clean-c

clean: clean-ada clean-c

.PHONY: clean clean-ada clean-c kazoo-ada kazoo-c gdb-ada gdb-c c ada skeletons-c clean-skeletons
