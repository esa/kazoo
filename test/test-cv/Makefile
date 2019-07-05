KAZOO=../../kazoo

all: test-parse
	make -C output
	cp obsw.pr output/obsw/SDL/src
	cd output/concurrency_view && \
	ocarina -x main.aadl && \
	    make -f Makefile.taste

c: # Polyorb_HI_C output
	$(KAZOO) -p --gw --glue --debug -o output_pohic && \
	    make -C output_pohic && \
    	    cp obsw.pr output_pohic/obsw/SDL/src && \
    	    cd output_pohic/concurrency_view && \
    	    ocarina -x main.aadl && \
	    make -f Makefile.taste

test-parse: clean
	$(KAZOO) --gw \
	         -o output \
	         --glue \
	         --debug

test-parse-c: clean
	$(KAZOO) -p --gw \
	         -o output \
	         --glue
buildsupport_pohic:
	buildsupport -o buildsupport_pohic -p --aadlv2 --glue -i InterfaceView.aadl -c DeploymentView.aadl -d DataView.aadl ../common/ocarina_components.aadl ../common/TASTE_IV_Properties.aadl ../common/TASTE_DV_Properties.aadl

buildsupport_pohiada:
	buildsupport -o buildsupport_ada --aadlv2 --glue -i InterfaceView.aadl -c DeploymentView.aadl -d DataView.aadl ../common/ocarina_components.aadl ../common/TASTE_IV_Properties.aadl ../common/TASTE_DV_Properties.aadl

gdb: clean
	gdb --args $(KAZOO) --gw \
	               -o output \
	               --glue \
		       --debug

clean:
	rm -rf output

.PHONY: clean test-parse gdb
