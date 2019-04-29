KAZOO=../../kazoo

all: test-parse

test-parse: clean
	$(KAZOO) --gw \
	               -o output \
	               --glue \
		       --debug \
	2>&1 | tail -1 | diff expected -

clean:
	rm -rf output

.PHONY: clean test-parse
