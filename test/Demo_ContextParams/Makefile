KAZOO?=kazoo

all:	c ada
	./regression.py

c:	work/glue_built
	cp passive_function/passive_function.c work/passive_function/C/src
	cp cyclic_function/cyclic_function.c work/cyclic_function/C/src
	cp function_in_ada/function_in_ada.adb work/function_in_ada/Ada/src
	$(MAKE) -C work

ada:	work/glue_built_ada
	cp passive_function/passive_function.c work_ada/passive_function/C/src
	cp cyclic_function/cyclic_function.c work_ada/cyclic_function/C/src
	cp function_in_ada/function_in_ada.adb work_ada/function_in_ada/Ada/src
	$(MAKE) -C work_ada

skeletons:	InterfaceView.aadl DataView.aadl
	$(KAZOO) --gw -o work
	$(MAKE) -C work dataview

work/glue_built:	InterfaceView.aadl DeploymentView.aadl DataView.aadl
	$(KAZOO) -p --glue --gw -o work
	touch work/glue_built

work/glue_built_ada:	InterfaceView.aadl DeploymentView.aadl DataView.aadl
	$(KAZOO) --glue --gw -o work_ada
	touch work/glue_built

clean:
	rm -rf work work_ada

soft-clean:
	$(MAKE) -C work clean
	$(MAKE) -C work_ada clean

.PHONY: clean skeletons c
