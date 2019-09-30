KAZOO=../../kazoo

all: test-parse
	$(MAKE) -C output.pohic

test-parse: clean
	$(KAZOO) --gw -p --glue -o output.pohic

buildsupport_pohic:
	buildsupport -o output.buildsupport.pohic -p --aadlv2 --glue -i InterfaceView.aadl -c DeploymentView.aadl -d DataView.aadl ../common/ocarina_components.aadl ../common/TASTE_IV_Properties.aadl ../common/TASTE_DV_Properties.aadl

clean:
	rm -rf output.pohic output.buildsupport.pohic

.PHONY: clean test-parse
