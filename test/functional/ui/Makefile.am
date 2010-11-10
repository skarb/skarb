check-local:
	env RUBYLIB=$(top_srcdir)/src/compiler $(RUBY) uitester.rb \
		$(top_srcdir)/src/compiler/rubyc.rb
clean-local:
	-rm -f a.out output.c
