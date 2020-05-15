KAZOO=../../kazoo

all: c

c: test-parse-c # Polyorb_HI_C output
	cp inputs/f1.c work/f1/C/src
	cp inputs/f2.c work/f2/C/src
	make -C work

test-parse-c: clean-c
	$(KAZOO) -p --gw \
	         -o work \
	         --glue -g

gdb: clean
	gdb --args $(KAZOO) --gw -p \
	               -o work \
	               --glue \
		       --debug

clean-c:
	rm -rf work

skeletons:
	$(KAZOO) -p --gw --glue -o work && make -C work dataview

clean-skeletons:
	rm -rf work

clean: clean-c clean-skeletons

.PHONY: clean simu clean-c gdb test-parse-c buildsupport_pohic buildsupport_pohiada c skeletons clean-skeletons
