SUBDIRS = src test
EXTRA_DIST = README.md
.PHONY: coverage benchmark

coverage: all
	make coverage -C test

benchmark: all
	make benchmark -C test
