SUBDIRS = . ui
TESTSCRIPTS = if.rb \
              puts.rb
TESTS_ENVIRONMENT = RUBYC_PATH=$(top_srcdir)/src/compiler/rubyc.rb \
                    TESTS="$(TESTSCRIPTS)" $(RUBY) -I $(top_srcdir)/src/compiler
TESTS = runner.rb
dist_noinst_DATA = $(TESTSCRIPTS) $(TESTS)
