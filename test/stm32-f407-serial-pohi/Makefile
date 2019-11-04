KAZOO=../../kazoo

all: c

c: test-parse
	cp function1/function1.pr work/function1/SDL/src
	cp function2/function2.adb work/function2/Ada/src
	make -C work

test-parse: clean-c
	$(KAZOO) --gw \
	         -o work \
	         --glue -g

gdb: clean
	gdb --args $(KAZOO) --gw \
	               -o work \
	               --glue \
		       --debug

skeletons:
	$(KAZOO) --gw --glue -o code && make -C work dataview

clean-skeletons:
	rm -rf work

clean-c:
	rm -rf work

clean: clean-c

.PHONY: clean clean-c gdb test-parse-c skeletons clean-skeletons
