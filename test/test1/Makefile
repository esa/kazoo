AADL_PARSER=../../aadl_parser

all: test-parse

test-parse:
	$(AADL_PARSER) -glue -i interfaceview.aadl \
	                     -c deploymentview.aadl \
			     -d dataview.aadl \
			     ../common/ocarina_components.aadl \
			     ../common/TASTE_DV_Properties.aadl \
			     2>&1 | tail -2 | diff expected -

clean:
	rm -rf obj $(exec) *~

.PHONY: clean test-parse
