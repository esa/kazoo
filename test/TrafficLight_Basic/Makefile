KAZOO?=kazoo

all:	c

c:	work/glue_built
	cp input/controller.pr work/controller/SDL/src
	$(MAKE) -C work
	cp input/*.png input/UserWidgets.py work/binaries/user_GUI


edit:
	taste

skeletons:
	$(MAKE) work/skeletons_built

work/skeletons_built:	InterfaceView.aadl DataView.aadl
	$(KAZOO) --gw -o work
	$(MAKE) -C work dataview
	touch work/skeletons_built

work/glue_built:	InterfaceView.aadl DeploymentView.aadl DataView.aadl
	$(KAZOO) -p --glue --gw -o work
	touch work/glue_built

clean:
	rm -rf work

.PHONY: clean skeletons c

