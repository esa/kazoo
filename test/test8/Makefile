KAZOO=../../kazoo

all: test-parse
	$(MAKE) -C work

test-parse: clean
	$(KAZOO) --gw -p --glue --debug

clean:
	rm -rf work

.PHONY: clean test-parse
