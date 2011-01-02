TESTSCRIPTS = ackermann.rb
BENCHMARK = RUBYC_PATH=$(top_builddir)/src/compiler/rubyc \
            CFLAGS="-I$(top_builddir)/src/stdlib" \
            LD_LIBRARY_PATH="$(top_builddir)/src/stdlib/.libs" \
            LDFLAGS="-L$(top_builddir)/src/stdlib/.libs" \
            TESTS="$(TESTSCRIPTS)" srcdir=$(srcdir) RUBY=$(RUBY) \
            $(RUBY) -I $(top_srcdir)/src/compiler \
            -I $(top_builddir)/src/compiler $(srcdir)/runner.rb
dist_noinst_DATA = $(TESTSCRIPTS) runner.rb
.PHONY: benchmark

benchmark:
	$(BENCHMARK)
