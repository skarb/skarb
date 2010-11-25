SUBDIRS = unit functional
.PHONY: coverage
dist_noinst_DATA = coverage.rb

coverage:
	srcdir=$(srcdir) builddir=$(builddir) top_srcdir=$(top_srcdir) \
		CFLAGS="-I$(top_srcdir)/src/stdlib" \
		RUBYC_PATH=$(top_builddir)/src/compiler/rubyc.rb \
		$(RUBY) -I $(top_srcdir)/src/compiler $(srcdir)/coverage.rb
	@echo See the report: file://$(abs_builddir)/coverage/index.html

clean-local:
	-rm -rf coverage
