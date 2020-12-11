KAZOO?=kazoo
# Here you can specify folders containing external code you want to
# compile and link for a specific partition.
# Use upper case for the partition name:
# export <PARTITION_NAME>_EXTERNAL_SOURCE_PATH=/absolute/path/1:/....

all:	sw

c:	work/glue_built
	rsync -c input/function1.c work/function1/C/src
	rsync -c input/function2.c work/function2/C/src
	$(MAKE) -C work

sw:	
	$(MAKE) NO_BITFILE=1 c

skeletons:
	$(MAKE) work/skeletons_built

work/skeletons_built:	InterfaceView.aadl DataView.aadl
	$(KAZOO) --gw -o work
	$(MAKE) -C work dataview
	touch $@

work/glue_built:	InterfaceView.aadl DeploymentView.aadl DataView.aadl
	$(KAZOO) -p --glue --gw -o work
	touch $@

DataView.aadl:	DataView.asn
	taste-update-data-view

clean:
	rm -rf work/build
	rm -f work/glue_built work/skeletons_built
	find work -type d -name "wrappers" -exec rm -rf {} +
	find work -type d -name "*_GUI" -exec rm -rf {} +

.PHONY: clean skeletons c

