KAZOO?=kazoo

all:	c

c:	work/glue_built
	$(MAKE) -C work

skeletons:	InterfaceView.aadl DataView.aadl
	$(KAZOO) --gw -o work
	$(MAKE) -C work dataview

work/glue_built:	InterfaceView.aadl DeploymentView.aadl DataView.aadl ConcurrencyView_Properties.aadl
	$(KAZOO) --glue --gw -o work
	touch work/glue_built

clean:
	rm -rf work
	git checkout -- .

.PHONY: clean skeletons c

