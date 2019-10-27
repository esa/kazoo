KAZOO?=kazoo

all:	c

c:	work/glue_built
	$(MAKE) -C work

skeletons:	InterfaceView.aadl DataView.aadl
	$(KAZOO) --gw -o work
	$(MAKE) -C work dataview

work/glue_built:	InterfaceView.aadl DeploymentView.aadl DataView.aadl
	$(KAZOO) -p --glue --gw -o work
	touch work/glue_built

clean:
	$(MAKE) -C work clean

.PHONY: clean skeletons c

