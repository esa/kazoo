KAZOO=../../kazoo

all: test-parse
	$(MAKE) -C work

test-parse: clean
	$(KAZOO) --gw \
	         -o work \
	         --glue \
	         --debug

gdb: clean
	gdb --args $(KAZOO) --gw \
	               -o work \
	               --glue \
		       --debug

clean:
	rm -rf work

.PHONY: clean test-parse gdb
