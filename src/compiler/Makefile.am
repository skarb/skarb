SUBDIRS = emitter translator
dist_bin_SCRIPTS = rubyc.rb
dist_pkgdata_DATA = compiler.rb emitter.rb helpers.rb parser.rb rubyc.rb \
                 translator.rb extensions.rb
dist_noinst_DATA = rubyc.rb.in

rubyc.rb: rubyc.rb.in
	sed -e s:RUBY_PATH:$(RUBY):g -e s:RUBYC_LIBDIR:$(pkgdatadir):g $< > $@

clean-local:
	rm -f rubyc.rb
