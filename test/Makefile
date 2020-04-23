DISABLED_TESTS=common/ shared-components/ logs/
export EXPECTED_FAILURES=test-stm32/ air-iop1 stm32-serial-pohiada2 test-air-portnames stm32-f407-serial-pohi test-air-multiports test-air-interpartcomm  stm32-f407-serial  test-air-2cyclics stm32-f407-encodeReal TrafficLight_stm32f407_NonDistrib TrafficLight_stm32f407 msp430_cyclic_calls_protected msp430_cyclic_calls_sporadic msp430_cyclic_calls_unprotected msp430_protected_calls_protected msp430_protected_calls_sporadic msp430_protected_calls_unprotected msp430_sporadic_calls_protected msp430_sporadic_calls_sporadic msp430_sporadic_calls_unprotected msp430_unprotected_calls_protected msp430_unprotected_calls_sporadic msp430_unprotected_calls_unprotected 
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
