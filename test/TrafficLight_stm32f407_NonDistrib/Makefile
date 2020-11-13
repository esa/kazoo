KAZOO?=kazoo

all:	c

c:	work/glue_built
	cp -u input/controller.pr work/controller/SDL/src/
	cp -u input/stm32_debug.adb work/stm32_debug/Ada/src/
	cp -u input/watchdog.pr work/watchdog/SDL/src/
	$(MAKE) -C work

skeletons:	InterfaceView.aadl DataView.aadl
	$(KAZOO) --gw -o work
	$(MAKE) -C work dataview

work/glue_built:	InterfaceView.aadl DeploymentView.aadl DataView.aadl
	$(KAZOO) --glue --gw -o work
	touch work/glue_built

clean:
	rm -rf work

.PHONY: clean skeletons c

