DISABLED_TESTS=common/
TEST_CASES=$(filter-out $(DISABLED_TESTS), $(sort $(dir $(wildcard */))))

test-parse:
	@python3 test.py test-parse $(TEST_CASES)

clean:
	@for v in $(TEST_CASES) ; \
		do $(MAKE) -s -C $$v clean ; \
	done

.PHONY: test-parse clean
