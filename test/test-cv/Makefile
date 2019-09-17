KAZOO=../../kazoo

all: c ada

ada: test-parse-ada
	cp input_data/obsw.pr output.ada/obsw/SDL/src
	cp input_data/gnc.c output.ada/gnc/C/src
	make -C output.ada

c: test-parse-c # Polyorb_HI_C output
	cp input_data/obsw.pr output.pohic/obsw/SDL/src
	cp input_data/gnc.c output.pohic/gnc/C/src
	$(MAKE) -C output.pohic

test-parse-ada: clean-ada
	$(KAZOO) --gw \
	         -o output.ada \
	         --glue \
	         --debug

test-parse-c: clean-c
	$(KAZOO) -p --gw \
	         -o output.pohic \
	         --glue --debug
buildsupport_pohic:
	buildsupport -o output.buildsupport.pohic -p --aadlv2 --glue -i InterfaceView.aadl -c DeploymentView.aadl -d DataView.aadl ../common/ocarina_components.aadl ../common/TASTE_IV_Properties.aadl ../common/TASTE_DV_Properties.aadl

buildsupport_pohiada:
	buildsupport -o output.buildsupport.ada --aadlv2 --glue -i InterfaceView.aadl -c DeploymentView.aadl -d DataView.aadl ../common/ocarina_components.aadl ../common/TASTE_IV_Properties.aadl ../common/TASTE_DV_Properties.aadl

gdb: clean
	gdb --args $(KAZOO) --gw \
	               -o output.pohic \
	               --glue \
		       --debug

clean-ada:
	rm -rf output.ada

clean-c:
	rm -rf output.pohic

skeletons:
	$(KAZOO) -p --gw --glue -o code && make -C code dataview

clean-skeletons:
	rm -rf code

clean: clean-ada clean-c clean-skeletons

.PHONY: clean clean-ada clean-c test-parse-ada gdb test-parse-c buildsupport_pohic buildsupport_pohiada c skeletons clean-skeletons
