KAZOO=../../kazoo

all: test-parse
	make -C output.ada
	cp obsw.pr output.ada/obsw/SDL/src
	cd output.ada/concurrency_view && \
	ocarina -x main.aadl && \
	    make -f Makefile.taste

c: test-parse-c # Polyorb_HI_C output
	make -C output.pohic && \
    	cp obsw.pr output.pohic/obsw/SDL/src && \
    	cd output.pohic/concurrency_view && \
    	ocarina -x main.aadl && \
	make -f Makefile.taste

test-parse: clean
	$(KAZOO) --gw \
	         -o output.ada \
	         --glue \
	         --debug

test-parse-c: clean
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

clean:
	rm -rf output.ada output.pohic

.PHONY: clean test-parse gdb test-parse-c buildsupport_pohic buildsupport_pohiada c
