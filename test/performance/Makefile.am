TESTSCRIPTS = binary_trees.rb ackermann.rb heapsort.rb matrix.rb strings.rb \
	      quicksort.rb arrays.rb arithmetic_expressions.rb
BENCHMARK = SKARB_PATH=$(top_builddir)/src/compiler/skarb \
            CFLAGS="-I$(top_builddir)/src/stdlib" \
            LD_LIBRARY_PATH="$(top_builddir)/src/stdlib/.libs" \
            LDFLAGS="-L$(top_builddir)/src/stdlib/.libs" \
            TESTS="$(TESTSCRIPTS)" srcdir=$(srcdir) RUBY=$(RUBY) \
            rspec -I $(top_srcdir)/src/compiler $(srcdir)/runner.rb
dist_noinst_DATA = $(TESTSCRIPTS) runner.rb
.PHONY: benchmark

benchmark:
	$(BENCHMARK)
