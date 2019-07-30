KAZOO=../../kazoo

all: test-parse
	cp input_data/hello.c output/hello/C/src && \
	    cp input_data/read.c output/read/C/src && \
	cd output && make air

test-parse: clean
	$(KAZOO) --gw -p \
	         -o output \
	         --glue \
		 --no-stdlib \
	         --debug \
		 ../common/libhw.aadl


gdb: clean
	gdb --args $(KAZOO) --gw -p \
	               -o output \
	               --glue \
		 --no-stdlib \
		 ../common/libhw.aadl \
		       --debug

clean:
	rm -rf output

.PHONY: clean test-parse gdb
