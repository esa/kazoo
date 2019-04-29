KAZOO=../../kazoo

all: test-parse

test-parse: clean
	$(KAZOO) --gw \
	               -o output \
	               --glue \
		       --debug && cd output && time make dataviews

gdb: clean
	gdb --args $(KAZOO) --gw \
	               -o output \
	               --glue \
		       --debug \
		       -i InterfaceView.aadl \
		       -c DeploymentView.aadl \
		       -d DataView.aadl \
		       ../common/ocarina_components.aadl && cd output && time make dataviews

clean:
	rm -rf output

.PHONY: clean test-parse gdb
