KAZOO=../../kazoo

all: test-parse
	cp input_data/helloworld1.c work/helloworld1/C/src
	cp input_data/helloworld2.c work/helloworld2/C/src
	make -C work air

test-parse: clean
	$(KAZOO) --gw -p \
	         -o work \
	         --glue \
		 --no-stdlib \
	         --debug \
		 ../common/ocarina_components.aadl

skeletons:
	$(MAKE) -C work skeletons

gdb: clean
	gdb --args $(KAZOO) --gw -p \
	               -o output \
	               --glue \
		 --no-stdlib \
	         --debug \
		 ../common/ocarina_components.aadl

clean:
	rm -rf work

.PHONY: clean test-parse gdb
