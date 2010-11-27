SUBDIRS = . ui
TESTSCRIPTS = if.rb \
              if-else.rb \
              if-elsif.rb \
              puts.rb \
              unless-else.rb \
              unless.rb \
              while-break.rb \
              until.rb \
              simple-function-without-arguments.rb
TESTS_ENVIRONMENT = RUBYC_PATH=$(top_srcdir)/src/compiler/rubyc.rb \
                    CFLAGS="-I$(top_srcdir)/src/stdlib" \
                    LDFLAGS="-static -L$(top_builddir)/src/stdlib/.libs" \
                    TESTS="$(TESTSCRIPTS)" $(RUBY) -I $(top_srcdir)/src/compiler
TESTS = runner.rb
dist_noinst_DATA = $(TESTSCRIPTS) $(TESTS)
