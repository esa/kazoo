KAZOO=../../kazoo

all: test-parse
	$(MAKE) -C output.pohic

test-parse: clean
	$(KAZOO) --gw -p --debug --glue -o output.pohic

clean:
	rm -rf output

.PHONY: clean test-parse
