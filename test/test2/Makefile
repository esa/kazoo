AADL_PARSER=../../aadl_parser

all: build

test-parse:
	$(AADL_PARSER) -gw -i InterfaceView.aadl -d DataView.aadl ../common/TASTE_IV_Properties.aadl

clean:
	rm -rf obj $(exec) *~

.PHONY: clean test-parse
