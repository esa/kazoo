AADL_PARSER=../../aadl_parser

all: test-parse

test-parse:
	$(AADL_PARSER) --gw \
	               --glue \
		       -i InterfaceView.aadl \
		       -c DeploymentView.aadl \
		       -d DataView.aadl \
		       ocarina_components.aadl \
		       2>&1 | tail -1 | diff expected -

clean:
	rm -rf obj $(exec) *~

.PHONY: clean test-parse
