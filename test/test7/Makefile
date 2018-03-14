AADL_PARSER=../../aadl_parser
all: test-parse
 		

test-parse: clean
	$(AADL_PARSER) -o output -i InterfaceView.aadl -d DataView.aadl ../common/TASTE_IV_Properties.aadl \
        2>&1 | tail -2 | diff expected -

clean:
	rm -rf output

.PHONY: clean test-parse
