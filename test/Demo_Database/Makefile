KAZOO=../../kazoo

all: c

c: test-parse-c # Polyorb_HI_C output
	taste-create-database
	cp displayer/displayer.adb work/displayer/Ada/src
	cp router/router.adb work/router/Ada/src
	make -C work
	[ -f work/binaries/mygui_GUI/sql_db/demo_database_getset.so ]

test-parse-c: clean-c
	$(KAZOO) -p --gw \
	         -o work \
	         --glue

gdb: clean
	gdb --args $(KAZOO) --gw \
	               -o work \
	               --glue \
		       --debug

clean-c:
	rm -rf work

skeletons:
	$(KAZOO) -p --gw --glue -o work && make -C work dataview

clean-skeletons:
	rm -rf work

clean: clean-c

.PHONY: clean clean-c gdb test-parse-c c skeletons clean-skeletons
