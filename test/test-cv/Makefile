KAZOO=../../kazoo

all: test-parse

test-parse: clean
	$(KAZOO) --gw \
	               -o output \
	               --glue \
		       --debug \
		       ../common/ocarina_components.aadl

gdb: clean
	gdb --args $(KAZOO) --gw \
	               -o output \
	               --glue \
		       --debug \
		       ../common/ocarina_components.aadl

clean:
	rm -rf output

.PHONY: clean test-parse gdb
