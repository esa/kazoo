KAZOO?=kazoo
# Here you can specify folders containing external code you want to
# compile and link for a specific partition.
# Use upper case for the partition name:
# export <PARTITION_NAME>_EXTERNAL_SOURCE_PATH=/absolute/path/1:/....

all:	c

c:	work/glue_built
	cp input_data/test_me.pr work/test_me/SDL/src/
	cp input_data/toto.adb work/toto/Ada/src/
	$(MAKE) -C work

skeletons:
	$(MAKE) work/skeletons_built

work/skeletons_built:	InterfaceView.aadl DataView.aadl
	$(KAZOO) --gw -o work
	$(MAKE) -C work dataview
	touch $@

work/glue_built:	clean
	$(KAZOO) -p --glue --gw -o work
	touch $@

clean:
	rm -rf work

.PHONY: clean skeletons c

