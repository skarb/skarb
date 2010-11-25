SUBDIRS = emitter translator
dist_bin_SCRIPTS = rubyc.rb
dist_pkgdata_DATA = compiler.rb emitter.rb helpers.rb parser.rb rubyc.rb \
                 translator.rb extensions.rb config.rb
dist_noinst_DATA = rubyc.rb.in config.rb.in

config.rb: config.rb.in
	sed -e s:RUBYC_INCLUDE_DIR:$(rubycincludedir):g $< > $@

rubyc.rb: rubyc.rb.in
	sed -e s:RUBY_PATH:$(RUBY):g -e s:RUBYC_LIBDIR:$(pkgdatadir):g $< > $@

clean-local:
	rm -f config.rb rubyc.rb
