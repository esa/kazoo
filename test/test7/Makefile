AADL_PARSER=../../aadl_parser
all: test-parse
 		

test-parse: clean
	$(AADL_PARSER) --check-dataview \
        2>&1 | tail -2 | diff expected -

clean:
	rm -rf output

.PHONY: clean test-parse
