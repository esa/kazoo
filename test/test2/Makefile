KAZOO=../../kazoo

all: test-parse
	$(MAKE) -C work

generate:
	$(KAZOO) --gw \
	         -p \
                 -o work \
                 --glue \
                 --debug

test-parse: clean generate

clean:
	rm -rf work

.PHONY: clean test-parse
