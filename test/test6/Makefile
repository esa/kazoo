AADL_PARSER=../../aadl_parser

all: test-parse

test-parse: clean
	$(AADL_PARSER) --gw \
	               --debug \
	               -o output \
#		       2>&1 | tail -1 | diff expected -

clean:
	rm -rf output

.PHONY: clean test-parse
