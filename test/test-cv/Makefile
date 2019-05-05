KAZOO=../../kazoo

all: test-parse
	make -C output
	cd output/concurrency_view && \
	ocarina -x main.aadl && \
	    make -f Makefile.taste


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
