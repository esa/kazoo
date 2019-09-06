KAZOO=../../kazoo

all: c

ada: test-parse-ada
	make -C output.ada
	cp a/a.c output.pohic/a/C/src
	cp b/b.c output.pohic/b/C/src
	cp c/c.c output.pohic/c/C/src
	cd output.ada/build && \
	ocarina -x main.aadl && \
	    make -f Makefile.taste

c: test-parse-c # Polyorb_HI_C output
	cp a/a.c output.pohic/a/C/src
	cp b/b.c output.pohic/b/C/src
	cp c/c.c output.pohic/c/C/src
	make -C output.pohic

test-parse-ada: clean-ada
	$(KAZOO) --gw \
	         -o output.ada \
	         --glue \
	         --debug

test-parse-c: clean-c
	$(KAZOO) -p --gw \
	         -o output.pohic \
	         --glue -g
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
