KAZOO=../../kazoo

all: c

c: test-parse-c # Polyorb_HI_C output
	cp livesingr740/livesingr740.c work/livesingr740/C/src
	cp livesinx86/livesinx86.c work/livesinx86/C/src
	make -C work

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
	$(KAZOO) -p --gw --glue -o code && make -C work dataview

clean-skeletons:
	rm -rf work

clean-c:
	rm -rf work

clean: clean-c

.PHONY: clean clean-c gdb test-parse-c buildsupport_pohic c skeletons clean-skeletons
