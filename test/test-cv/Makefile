KAZOO=../../kazoo

all: test-parse
	cp InterfaceView.aadl output/concurrency_view && \
	cp DeploymentView.aadl output/concurrency_view && \
	cp DataView.aadl output/concurrency_view/D_view.aadl && \
	cd output/concurrency_view && ocarina -x main.aadl

test-parse: clean
	$(KAZOO) --gw \
	         -o output \
	         --glue \
	         --debug

gdb: clean
	gdb --args $(KAZOO) --gw \
	               -o output \
	               --glue \
		       --debug

clean:
	rm -rf output

.PHONY: clean test-parse gdb
