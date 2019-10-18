KAZOO=../../kazoo

all: c

c: test-parse
	cp beater/beater.pr work/beater/SDL/src
	cp pinglogger/pinglogger.pr work/pinglogger/SDL/src
	cp driver/driver.c work/driver/C/src
	cp manager/manager.pr work/manager/SDL/src
	cp stm32_debug/stm32_debug.adb work/stm32_debug/Ada/src
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
	$(KAZOO) --gw --glue -o work && make -C work dataview

clean-skeletons:
	rm -rf work

clean-c:
	rm -rf work

clean: clean-c

.PHONY: clean clean-c gdb test-parse-c skeletons clean-skeletons
