KAZOO=../../kazoo

all: test-parse
	$(MAKE) -C output.pohic

test-parse: clean
	$(KAZOO) --gw -p \
	               -o output.pohic \
	               --glue \
		       --debug

clean:
	rm -rf output.pohic

.PHONY: clean test-parse
