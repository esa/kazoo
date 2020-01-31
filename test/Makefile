DISABLED_TESTS=common/ shared-components/
TEST_CASES=$(sort $(filter-out $(DISABLED_TESTS), $(dir $(wildcard */))))
export MAKEFLAGS="-j $(grep -c ^processor /proc/cpuinfo)"

all:
	@python3 test.py all $(TEST_CASES)

test-parse:
	@python3 test.py test-parse $(TEST_CASES)

clean:
	@for v in $(TEST_CASES) ; \
		do $(MAKE) -s -C $$v clean ; \
	done

.PHONY: test-parse clean
