KAZOO=../../kazoo

all: test-parse
	cd output/concurrency_view && ocarina -x main.aadl

test-parse: clean
	$(KAZOO) --gw \
	         -o output \
	         --glue \
		 --no-stdlib \
	         --debug \
		 ../common/libhw.aadl


gdb: clean
	gdb --args $(KAZOO) --gw \
	               -o output \
	               --glue \
		       --debug

clean:
	rm -rf output

.PHONY: clean test-parse gdb
