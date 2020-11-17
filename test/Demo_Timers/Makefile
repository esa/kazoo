KAZOO=../../kazoo

all: c

c: test-parse-c # Polyorb_HI_C output
	cp ada_fct/ada_fct.adb work/ada_fct/Ada/src
	cp function2/function2.c work/function2/C/src
	cp sdl_fct/sdl_fct.pr work/sdl_fct/SDL/src
	make -C work

simu: clean-c
	$(KAZOO) -p -t SIMU --gw -o work --glue -g
	$(MAKE) -C work dataview
	cp ada_fct/ada_fct.adb work/ada_fct/Ada/src
	cp function2/function2.c work/function2/C/src
	cp sdl_fct/sdl_fct.pr work/sdl_fct/SDL/src

test-parse-c: clean-c
	$(KAZOO) -p --gw \
	         -o work \
	         --glue -g
buildsupport_pohic:
	buildsupport -o output.buildsupport.pohic -p --aadlv2 --glue -i InterfaceView.aadl -c DeploymentView.aadl -d DataView.aadl ../common/ocarina_components.aadl ../common/TASTE_IV_Properties.aadl ../common/TASTE_DV_Properties.aadl

gdb: clean
	gdb --args $(KAZOO) --gw \
	               -o work \
	               --glue \
		       --debug

skeletons:
	$(KAZOO) -p --gw --glue -o work && make -C work dataview

clean-skeletons:
	rm -rf work

clean-c:
	rm -rf work

clean: clean-c

.PHONY: simu clean clean-c gdb test-parse-c buildsupport_pohic c skeletons clean-skeletons
