KAZOO=../../kazoo

# this project is POHIAda only
all: ada

ada: test-parse-ada
	cp function1/function1.c output.ada/function1/C/src
	cp function2/function2.c output.ada/function2/C/src
	make -C output.ada

test-parse-ada: clean-ada
	$(KAZOO) --gw \
	         -o output.ada \
	         --glue \
	         --debug

buildsupport_pohiada:
	buildsupport -o output.buildsupport.ada --aadlv2 --glue -i InterfaceView.aadl -c DeploymentView.aadl -d DataView.aadl ../common/ocarina_components.aadl ../common/TASTE_IV_Properties.aadl ../common/TASTE_DV_Properties.aadl

gdb: clean
	gdb --args $(KAZOO) --gw \
	               -o output.pohic \
	               --glue \
		       --debug

clean-ada:
	rm -rf output.ada

skeletons:
	$(KAZOO) -p --gw --glue -o code && make -C code dataview

clean-skeletons:
	rm -rf code

clean: clean-ada clean-skeletons

.PHONY: clean clean-ada test-parse-ada gdb buildsupport_pohiada skeletons clean-skeletons
