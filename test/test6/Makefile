AADL_PARSER=../../aadl_parser

all: test-parse
	cd output && make

test-parse: clean
	$(AADL_PARSER) --gw \
	               --debug \
	               -o output

clean:
	rm -rf output

.PHONY: clean test-parse
