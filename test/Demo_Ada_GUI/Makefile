KAZOO=../../kazoo

all: c

ada: test-parse-ada
	make -C output.ada && \
	cp displayer/displayer.adb output.ada/displayer/Ada/src
	cp router/router.adb output.ada/router/Ada/src
	$(MAKE) -C output.ada

c: test-parse-c # Polyorb_HI_C output
	cp displayer/displayer.adb work/displayer/Ada/src
	cp router/router.adb work/router/Ada/src
	$(MAKE) -C work
	./regression.py
	./test.with.python.sh

simu: clean-c
	$(KAZOO) -t SIMU -p --gw --glue
	cp displayer/displayer.adb work/displayer/Ada/src
	cp router/router.adb work/router/Ada/src
	$(MAKE) -C work

test-parse-ada: clean-ada
	$(KAZOO) --gw \
	         -o output.ada \
	         --glue \
	         --debug

test-parse-c: clean-c
	$(KAZOO) -p --gw \
	         -o work \
	         --glue

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
	$(KAZOO) -p --gw --glue -o work && $(MAKE) -C work dataview

clean-skeletons:
	rm -rf work

clean: clean-ada clean-c clean-skeletons

.PHONY: clean clean-ada clean-c test-parse-ada gdb test-parse-c buildsupport_pohic buildsupport_pohiada c skeletons clean-skeletons
