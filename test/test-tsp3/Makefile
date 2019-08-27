KAZOO=../../kazoo

all: test-parse
	$(MAKE) -C output

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
		 --no-stdlib \
		 ../common/libhw.aadl \
		       --debug

clean:
	rm -rf output

.PHONY: clean test-parse gdb
