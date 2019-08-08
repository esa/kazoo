KAZOO=../../kazoo

all: test-parse
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
