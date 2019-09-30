KAZOO=../../kazoo

all: c

c: test-parse-c # Polyorb_HI_C output
	cp skels/a/a.c output.pohic/a/C/src
	cp skels/b/b.c output.pohic/b/C/src
	make -C output.pohic

test-parse-c: clean-c
	$(KAZOO) -p --gw \
	         -o output.pohic \
	         --glue -g
buildsupport_pohic:
	buildsupport -o output.buildsupport.pohic -p --aadlv2 --glue -i InterfaceView.aadl -c DeploymentView.aadl -d DataView.aadl ../common/ocarina_components.aadl ../common/TASTE_IV_Properties.aadl ../common/TASTE_DV_Properties.aadl

gdb: clean
	gdb --args $(KAZOO) --gw \
	               -o output.pohic \
	               --glue \
		       --debug

skeletons:
	$(KAZOO) -p --gw --glue -o code && make -C code dataview

clean-skeletons:
	rm -rf code

clean-c:
	rm -rf output.pohic

clean: clean-c clean-skeletons

.PHONY: clean clean-c gdb test-parse-c buildsupport_pohic c skeletons clean-skeletons
