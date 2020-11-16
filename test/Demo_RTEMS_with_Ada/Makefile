KAZOO?=kazoo

all:	c

c:	work/glue_built
	cp simple_ada/simple_ada.adb work/simple_ada/Ada/src/
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
	rm -rf work

.PHONY: clean skeletons c

