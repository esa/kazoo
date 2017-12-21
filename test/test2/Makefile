AADL_PARSER=../../aadl_parser

all: test-parse

test-parse:
	$(AADL_PARSER) --gw \
	               --glue \
		       -i InterfaceView.aadl \
		       -c DeploymentView.aadl \
		       -d DataView.aadl \
		       ../common/TASTE_IV_Properties.aadl \
		       ../common/ocarina_components.aadl \
		       ../common/TASTE_DV_Properties.aadl

clean:
	rm -rf obj $(exec) *~

.PHONY: clean test-parse
