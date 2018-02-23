AADL_PARSER=../../aadl_parser

all: test-parse

test-parse:
	$(AADL_PARSER) --gw \
	               -o output \
		       ../common/TASTE_IV_Properties.aadl
#		       2>&1 | tail -1 | diff expected -

clean:
	rm -rf obj $(exec) *~

.PHONY: clean test-parse
