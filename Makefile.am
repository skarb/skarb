SUBDIRS = src test
.PHONY: coverage rdoc benchmark

coverage: all
	make coverage -C test

benchmark: all
	make benchmark -C test

rdoc:
	make rdoc -C doc

clean-local:
	make clean -C gc-7.1

distclean-local:
	-rm -rf gc-7.1 gc-7.1.tar.gz
