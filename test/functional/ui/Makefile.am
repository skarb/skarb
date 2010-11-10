dist_noinst_DATA = uitester.rb
check-local:
	env RUBYLIB=$(top_srcdir)/src/compiler $(RUBY) $(srcdir)/uitester.rb \
		$(top_srcdir)/src/compiler/rubyc.rb
clean-local:
	-rm -f a.out output.c
