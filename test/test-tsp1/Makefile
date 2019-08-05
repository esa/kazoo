KAZOO=../../kazoo

all: test-parse
	cd output/build && ocarina -x main.aadl

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
	               --glue --no-stdlib \
		       --debug ../common/libhw.aadl

clean:
	rm -rf output

.PHONY: clean test-parse gdb
