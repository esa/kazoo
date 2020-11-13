KAZOO?=kazoo

all:	c

c:	work/glue_built
	$(MAKE) -C work

simu:
	$(KAZOO) -t SIMU --gw --glue -p 
	$(MAKE) -C work

skeletons:
	$(MAKE) work/skeletons_built

work/skeletons_built:	InterfaceView.aadl DataView.aadl
	$(KAZOO) --gw -o work
	$(MAKE) -C work dataview
	touch $@

work/glue_built:	InterfaceView.aadl DeploymentView.aadl DataView.aadl
	$(KAZOO) -p --glue --gw -o work
	touch $@

clean:
	$(MAKE) -C work clean

.PHONY: clean skeletons c

