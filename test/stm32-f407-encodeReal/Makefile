KAZOO=../../kazoo

all: c

c: test-parse
	cp function1/function1.pr work/function1/SDL/src
	cp function2/function2.adb work/function2/Ada/src
	cp function3/function3.c work/function3/C/src
	make -C work

test-parse:
	$(KAZOO) --gw \
	         -o work \
	         --glue -g

gdb:
	gdb --args $(KAZOO) --gw \
	               -o work \
	               --glue \
		       --debug

skeletons:
	$(KAZOO) -p --gw -o work && make -C work dataview

clean-skeletons:
	rm -rf work

clean-c:
	rm -rf work

clean: clean-c

.PHONY: clean clean-c gdb test-parse-c skeletons clean-skeletons
