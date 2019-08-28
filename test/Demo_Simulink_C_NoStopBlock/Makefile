KAZOO=../../kazoo

all: c

c: test-parse-c # Polyorb_HI_C output
	cp my_c_function/*.c output.pohic/my_c_function/C/src
	cp my_simulink_function/* output.pohic/my_simulink_function/SIMULINK/src
	make -C output.pohic

test-parse-c: clean-c
	$(KAZOO) -p --gw \
	         -o output.pohic \
	         --glue -g
buildsupport_pohic:
	buildsupport -o output.buildsupport.pohic -p --aadlv2 --glue -i InterfaceView.aadl -c DeploymentView.aadl -d DataView.aadl ../common/ocarina_components.aadl ../common/TASTE_IV_Properties.aadl ../common/TASTE_DV_Properties.aadl

buildsupport_pohiada:
	buildsupport -o output.buildsupport.ada --aadlv2 --glue -i InterfaceView.aadl -c DeploymentView.aadl -d DataView.aadl ../common/ocarina_components.aadl ../common/TASTE_IV_Properties.aadl ../common/TASTE_DV_Properties.aadl

gdb: clean
	gdb --args $(KAZOO) --gw -p \
	               -o output.pohic \
	               --glue \
		       --debug

clean-c:
	rm -rf output.pohic

skeletons:
	$(KAZOO) -p --gw --glue -o code && make -C code dataview

clean-skeletons:
	rm -rf code

clean: clean-c clean-skeletons

.PHONY: clean clean-c gdb test-parse-c buildsupport_pohic buildsupport_pohiada c skeletons clean-skeletons
