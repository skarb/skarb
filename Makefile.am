AM_DISTCHECK_CONFIGURE_FLAGS=--enable-tests
SUBDIRS = src
EXTRA_DIST = README.md
.PHONY: coverage benchmark

if TESTS

SUBDIRS += test

benchmark: all
	make benchmark -C test

if COVERAGE

coverage: all
	make coverage -C test

endif # COVERAGE

endif # TESTS
