KAZOO=../../kazoo

all: test-parse

test-parse:
	$(KAZOO) --glue -i interfaceview.aadl \
	                      -c deploymentview.aadl \
			      -d dataview.aadl \
			     2>&1 | tail -2 | diff expected -

clean:
	rm -rf obj $(exec) *~

.PHONY: clean test-parse
