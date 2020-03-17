DISABLED_TESTS=common/ shared-components/ logs/
export EXPECTED_FAILURES=test-stm32/ air-iop1
TEST_CASES=$(sort $(filter-out $(DISABLED_TESTS), $(dir $(wildcard */))))
export MAKEFLAGS="-j $(grep -c ^processor /proc/cpuinfo)"
MAKEFILE_PATH   := $(abspath $(lastword $(MAKEFILE_LIST)))
TEST_BASE_DIR   := $(dir $(MAKEFILE_PATH))

all:
	find . -name "DataView.aadl" -exec sed -i "s,/home/taste/tool-inst/share/taste-types,${TEST_BASE_DIR}/common,g" {} \;
	find . -name "DataView.aadl" -exec sed -i "s,/home/taste/tool-src/kazoo/test,${TEST_BASE_DIR},g" {} \;
	rm -f ${TEST_BASE_DIR}/logs/*
	python3 test.py all $(TEST_CASES)
	find . -name "DataView.aadl" -exec git checkout -- {} \;

test-parse:
	@python3 test.py test-parse $(TEST_CASES)

clean:
	@for v in $(TEST_CASES) ; \
		do $(MAKE) -s -C $$v clean ; \
	done

.PHONY: test-parse clean
