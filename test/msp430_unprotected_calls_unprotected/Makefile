KAZOO=../../kazoo
WORK_DIRECTORY=work

.PHONY: c clean distclean

all: test-parse
	$(MAKE) -C $(WORK_DIRECTORY)

test-parse: clean
	$(KAZOO) -p --gw \
	         -o $(WORK_DIRECTORY) \
	         --glue -g -k

clean:
	rm -rf $(WORK_DIRECTORY)
