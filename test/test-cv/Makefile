KAZOO=../../kazoo

all: ada c

ada: test-parse-ada
	make -C output.ada && \
	cp input_data/obsw.pr output.ada/obsw/SDL/src && \
	cp input_data/gnc.c output.ada/gnc/C/src && \
	cd output.ada/concurrency_view && \
	ocarina -x main.aadl && \
	    make -f Makefile.taste

c: test-parse-c # Polyorb_HI_C output
	make -C output.pohic && \
    	cp input_data/obsw.pr output.pohic/obsw/SDL/src && \
	cp input_data/gnc.c output.pohic/gnc/C/src && \
    	cd output.pohic/concurrency_view && \
    	ocarina -x main.aadl && \
	make -f Makefile.taste

test-parse-ada: clean-ada
	$(KAZOO) --gw \
	         -o output.ada \
	         --glue \
	         --debug

test-parse-c: clean-c
	$(KAZOO) -p --gw \
	         -o output.pohic \
	         --glue
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

clean: clean-ada clean-c

.PHONY: clean clean-ada clean-c test-parse-ada gdb test-parse-c buildsupport_pohic buildsupport_pohiada c
