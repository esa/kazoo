KAZOO=../../kazoo

all: test-parse
	cp input_data/hello.c work/hello/C/src && \
	    cp input_data/read.c work/read/C/src && \
	cd work && make air

test-parse: clean
	$(KAZOO) --gw -p \
	         -o work \
	         --glue \
		 --no-stdlib \
	         --debug \
		 ../common/libhw.aadl


gdb: clean
	gdb --args $(KAZOO) --gw -p \
	               -o work \
	               --glue \
		 --no-stdlib \
		 ../common/libhw.aadl \
		       --debug

clean:
	rm -rf work

.PHONY: clean test-parse gdb
