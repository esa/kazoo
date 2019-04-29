KAZOO=../../kazoo

all: test-parse

test-parse:
	$(KAZOO) --gw \
	               --glue \
		       -i InterfaceView.aadl \
		       -c DeploymentView.aadl \
		       -d DataView.aadl \
		       2>&1 | tail -1 | diff expected -

clean:
	rm -rf obj $(exec) *~

.PHONY: clean test-parse
