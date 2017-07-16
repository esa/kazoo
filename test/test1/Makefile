AADL_PARSER=../../aadl_parser

all: build

test-parse:
	$(AADL_PARSER) -glue -i interfaceview.aadl -c deploymentview.aadl -d dataview.aadl ../common/ocarina_components.aadl ../common/TASTE_DV_Properties.aadl

clean:
	rm -rf obj $(exec) *~

.PHONY: clean test-parse
