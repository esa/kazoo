KAZOO=../../kazoo

all: c ada

ada: test-parse-ada
	cp caller_in_c/caller_in_c.c output.ada/caller_in_c/C/src
	cp caller_in_ada/caller_in_ada.adb output.ada/caller_in_ada/Ada/src
	cp blackbox/blackbox.c output.ada/blackbox/Blackbox_C/src
	$(MAKE) -C output.ada

c: test-parse-c # Polyorb_HI_C output
	cp caller_in_c/caller_in_c.c work/caller_in_c/C/src
	cp caller_in_ada/caller_in_ada.adb work/caller_in_ada/Ada/src
	cp blackbox/blackbox.c work/blackbox/Blackbox_C/src
	$(MAKE) -C work

test-parse-ada: clean-ada
	$(KAZOO) --gw \
	         -o output.ada \
	         --glue \
	         --debug

test-parse-c: clean-c
	$(KAZOO) -p --gw \
	         -o work \
	         --glue --debug
buildsupport_pohic:
	buildsupport -o output.buildsupport.pohic -p --aadlv2 --glue -i InterfaceView.aadl -c DeploymentView.aadl -d DataView.aadl ../common/ocarina_components.aadl ../common/TASTE_IV_Properties.aadl ../common/TASTE_DV_Properties.aadl

buildsupport_pohiada:
	buildsupport -o output.buildsupport.ada --aadlv2 --glue -i InterfaceView.aadl -c DeploymentView.aadl -d DataView.aadl ../common/ocarina_components.aadl ../common/TASTE_IV_Properties.aadl ../common/TASTE_DV_Properties.aadl

gdb: clean
	gdb --args $(KAZOO) --gw \
	               -o work \
	               --glue \
		       --debug

clean-ada:
	rm -rf output.ada

clean-c:
	rm -rf work

skeletons:
	$(KAZOO) -p --gw --glue -o work && make -C work dataview

clean-skeletons:
	rm -rf work

clean: clean-ada clean-c clean-skeletons

.PHONY: clean clean-ada clean-c test-parse-ada gdb test-parse-c buildsupport_pohic buildsupport_pohiada c skeletons clean-skeletons
