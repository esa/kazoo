AADL_PARSER=../../aadl_parser

all: test-parse

test-parse: clean
	$(AADL_PARSER) --gw \
	               -o output \
	               --glue \
		       --debug \
		       -i InterfaceView.aadl \
		       -c DeploymentView.aadl \
		       -d DataView.aadl \
		       ../common/ocarina_components.aadl \
	2>&1 | tail -1 | diff expected -

clean:
	rm -rf output

.PHONY: clean test-parse
