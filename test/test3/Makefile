KAZOO=../../kazoo
all: test-parse
 		

test-parse: clean
	$(KAZOO) -o output -i InterfaceView.aadl -d DataView.aadl
		

clean:
	rm -rf output

.PHONY: clean test-parse
