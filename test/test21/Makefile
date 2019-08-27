KAZOO=../../kazoo

all: test-parse

test-parse: clean
	$(KAZOO) --gw -p -o output.pohic --glue --debug 
	time $(MAKE) -C output.pohic dataview

gdb: clean
	gdb --args $(KAZOO) --gw \
	               -o output.pohic \
		       -p \
	               --glue \
		       --debug

clean:
	rm -rf output.pohic

.PHONY: clean test-parse gdb
