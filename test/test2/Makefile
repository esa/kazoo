KAZOO=../../kazoo

all: test-parse
	cd output && make

generate:
	$(KAZOO) --gw \
	               -o output \
	               --glue \
		       --debug

test-parse: clean generate

clean:
	rm -rf output

.PHONY: clean test-parse
