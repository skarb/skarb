SUBDIRS = . ui
TESTSCRIPTS = if.rb \
              if-else.rb \
              if-elsif.rb \
              puts.rb \
              unless-else.rb \
              unless.rb \
              while.rb \
              while-break.rb \
              until.rb \
              zero-as-a-condition.rb \
              simple-functions.rb \
              local-vars.rb \
              overloading-functions.rb \
              class_declaration.rb \
              inheritance.rb \
              strings.rb \
              nil.rb \
              fixnum.rb \
              float.rb \
              dynamic-types.rb\
              array.rb \
              hash.rb \
              recur.rb \
              double-evaluation.rb \
              var-decls-in-funcs.rb \
              constants-overriding.rb \
              true-false.rb \
              global-vars.rb \
              empty-argv.rb \
              case.rb

TESTS_ENVIRONMENT = RUBYC_PATH=$(top_builddir)/src/compiler/rubyc \
                    CFLAGS="-I$(top_builddir)/src/stdlib" \
                    LD_LIBRARY_PATH="$(top_builddir)/src/stdlib/.libs" \
                    LDFLAGS="-L$(top_builddir)/src/stdlib/.libs" \
                    TESTS="$(TESTSCRIPTS)" $(RUBY) -I $(top_srcdir)/src/compiler \
                    -I $(top_builddir)/src/compiler
TESTS = runner.rb
dist_noinst_DATA = $(TESTSCRIPTS) $(TESTS)
