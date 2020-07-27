MAKEFILE_PATH   := $(abspath $(lastword $(MAKEFILE_LIST)))
OUTDIR          := $(dir $(MAKEFILE_PATH))
export X86_PARTITION_EXTERNAL_SOURCE_PATH=$(OUTDIR)/customCode
export LEON3_PARTITION_EXTERNAL_SOURCE_PATH=$(OUTDIR)/customCode
export X86_PARTITION_USER_CFLAGS=-DDEBUG=1
export X86_PARTITION_USER_LDFLAGS=-lrt -lm


KAZOO=../../kazoo

all: c

ada: test-parse-ada
	cp function1/function1.cc work/function1/CPP/src
	cp function2/function2.cc work/function2/CPP/src
	cp function2/function2_state.h work/function2/CPP/src
	$(MAKE) -C output.ada

c: test-parse-c # Polyorb_HI_C output
	cp function1/function1.cc work/function1/CPP/src
	cp function2/function2.cc work/function2/CPP/src
	cp function2/function2_state.h work/function2/CPP/src
	cp function1/function1.cc work.leon3/function1/CPP/src
	cp function2/function2.cc work.leon3/function2/CPP/src
	cp function2/function2_state.h work.leon3/function2/CPP/src
	$(MAKE) -C work
	$(MAKE) -C work.leon3

native:

test-parse-ada: clean-ada
	$(KAZOO) --gw \
	         -o output.ada \
	         --glue \
	         --debug

test-parse-c: clean-c
	$(KAZOO) -p \
	         -c DeploymentView_Native.aadl \
	         --gw \
	         -o work \
	         --glue -g
	$(KAZOO) -p \
	         -c DeploymentView_Leon3.aadl \
	         --gw \
	         -o work.leon3 \
	         --glue -g
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
	rm -rf work work.leon3

skeletons:
	$(KAZOO) -p --gw --glue -o work && make -C work dataview

clean-skeletons:
	rm -rf work

clean: clean-ada clean-c clean-skeletons

.PHONY: clean clean-ada clean-c test-parse-ada gdb test-parse-c buildsupport_pohic buildsupport_pohiada c skeletons clean-skeletons
