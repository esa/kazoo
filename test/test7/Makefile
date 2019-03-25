KAZOO=../../kazoo
all: test-parse
 		

test-parse: clean
	$(KAZOO) --check-dataview \
        2>&1 | tail -2 | diff expected -

clean:
	rm -rf output

.PHONY: clean test-parse
