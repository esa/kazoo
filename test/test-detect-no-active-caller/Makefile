KAZOO=../../kazoo

all: test-parse

test-parse: clean
	$(KAZOO) --gw \
	         -o output \
		 -p \
	         --glue \
		 --no-stdlib \
	         --debug \
		 ../common/libhw.aadl \
	2>&1 | tail -1 | diff expected -


gdb: clean
	gdb --args $(KAZOO) --gw \
	         -o output \
	         --glue \
		 -p \
		 --no-stdlib \
		 ../common/libhw.aadl \
		 --debug

clean:
	rm -rf output

.PHONY: clean test-parse gdb
