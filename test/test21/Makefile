KAZOO=../../kazoo

all: test-parse

test-parse: clean
	$(KAZOO) --gw -p -o work --glue --debug 
	bash -c "time ${MAKE} -C work dataview"

gdb: clean
	gdb --args $(KAZOO) --gw \
	               -o work \
		       -p \
	               --glue \
		       --debug

clean:
	rm -rf work

.PHONY: clean test-parse gdb
