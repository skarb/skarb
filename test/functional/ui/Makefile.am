dist_noinst_DATA = $(TESTSCRIPTS) $(TESTS) cc errorous_source.rb test_code.rb
TESTSCRIPTS = compile_from_stdin.sh create_a_binary.sh error_parse.sh \
              fail_from_stdin.sh help.sh no_options.sh set_compiler.sh \
              store_temporary_file_after_failure.sh output_binary_name.sh \
              emit_c_only.sh use_cc_by_default.sh dont_link.sh set_cflags.sh \
              unsupported.sh
check:
	RUBYLIB="$(top_builddir)/src/compiler:$(top_srcdir)/src/compiler" \
		RUBY=$(RUBY) CFLAGS="-I$(top_builddir)/src/stdlib" \
		LD_LIBRARY_PATH="$(top_builddir)/src/stdlib/.libs" \
		LDFLAGS="-L$(top_builddir)/src/stdlib/.libs" \
		SKARB="$(RUBY) $(top_builddir)/src/compiler/skarb" \
		TESTS="$(TESTSCRIPTS)" \
		srcdir="$(srcdir)" \
		$(RSPEC) -c -I $(top_srcdir)/src/compiler uitester.rb
