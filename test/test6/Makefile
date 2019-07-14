KAZOO=../../kazoo

all: test-parse
	cd output && make

test-parse: clean
	$(KAZOO) --gw --debug -o output

clean:
	rm -rf output

.PHONY: clean test-parse
