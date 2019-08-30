KAZOO=../../kazoo

all: test-parse
	$(MAKE) -C output

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
