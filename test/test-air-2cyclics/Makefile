KAZOO=../../kazoo

all: test-parse
	cp input_data/helloworld1.c output/helloworld1/C/src
	cp input_data/helloworld2.c output/helloworld2/C/src
	make -C output air

test-parse: clean
	$(KAZOO) --gw -p \
	         -o output \
	         --glue \
		 --no-stdlib \
	         --debug \
		 ../common/ocarina_components.aadl


gdb: clean
	gdb --args $(KAZOO) --gw -p \
	               -o output \
	               --glue \
		 --no-stdlib \
	         --debug \
		 ../common/ocarina_components.aadl

clean:
	rm -rf output

.PHONY: clean test-parse gdb
