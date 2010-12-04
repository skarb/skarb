SUBDIRS = src doc test
.PHONY: coverage rdoc

coverage: all
	make coverage -C test

rdoc:
	make rdoc -C doc

clean-local:
	make clean -C gc-7.1

distclean-local:
	-rm -rf gc-7.1 gc-7.1.tar.gz
