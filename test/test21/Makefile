KAZOO=../../kazoo

all: test-parse

test-parse: clean
	$(KAZOO) --gw \
	               -o output \
	               --glue \
		       --debug && time $(MAKE) -C output dataview

gdb: clean
	gdb --args $(KAZOO) --gw \
	               -o output \
	               --glue \
		       --debug \
		       -i InterfaceView.aadl \
		       -c DeploymentView.aadl \
		       -d DataView.aadl \
		       ../common/ocarina_components.aadl && $(MAKE) -C output dataview

clean:
	rm -rf output

.PHONY: clean test-parse gdb
