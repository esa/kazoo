KAZOO?=kazoo
# Here you can specify folders containing external code you want to
# compile and link for a specific partition.
# Use upper case for the partition name:
# export <PARTITION_NAME>_EXTERNAL_SOURCE_PATH=/absolute/path/1:/....

all:	c

c:	work/glue_built
	cp input/function1.pr work/function1/SDL/src
	cp input/function2.pr work/function2/SDL/src
	cp input/function3.c work/function3/C/src
	cp input/function4.c work/function4/C/src
	$(MAKE) -C work
	./regression.py

skeletons:
	$(MAKE) work/skeletons_built

work/skeletons_built:	InterfaceView.aadl DataView.aadl
	#taste-update-data-view
	$(KAZOO) --gw -o work
	$(MAKE) -C work dataview
	touch $@

work/glue_built:	InterfaceView.aadl DeploymentView.aadl DataView.aadl
	#taste-update-data-view
	$(KAZOO) -p --glue --gw -o work
	touch $@

clean:
	rm -rf work

.PHONY: clean skeletons c

