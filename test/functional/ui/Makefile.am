TESTSCRIPTS = compile_from_stdin.sh create_a_binary.sh error_parse.sh \
              fail_from_stdin.sh help.sh no_options.sh set_compiler.sh \
              store_temporary_file_after_failure.sh output_binary_name.sh
TESTS_ENVIRONMENT = RUBYLIB=$(top_srcdir)/src/compiler \
                    RUBYC="$(RUBY) $(top_srcdir)/src/compiler/rubyc.rb" \
                    TESTS="$(TESTSCRIPTS)" $(RUBY)
TESTS = uitester.rb
dist_noinst_DATA = $(TESTSCRIPTS) $(TESTS) fake_cc errorous_source.rb
clean-local:
	-rm -f a.out output.c
