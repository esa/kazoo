AADL_PARSER=../../aadl_parser

all: test-parse

test-parse:
	$(AADL_PARSER) -i InterfaceView.aadl -d DataView.aadl ../common/TASTE_IV_Properties.aadl

clean:
	rm -rf obj $(exec) *~

.PHONY: clean test-parse
