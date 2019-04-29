KAZOO=../../kazoo

all: test-parse

test-parse: clean
	$(KAZOO) --gw \
	               -o output \
	               --glue \
		       --debug 

clean:
	rm -rf output

.PHONY: clean test-parse
