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
		       ../common/ocarina_components.aadl && cd output && time make dataviews

clean:
	rm -rf output

.PHONY: clean test-parse
