SUBDIRS = emitter translator
nodist_bin_SCRIPTS = rubyc
nodist_pkgdata_DATA = config.rb
dist_pkgdata_DATA = compiler.rb emitter.rb helpers.rb parser.rb translator.rb \
                    extensions.rb manager.rb stdlib.rb classes_dict_builder.rb\
		    hash_builder.rb
dist_noinst_DATA = rubyc.rb.in config.rb.in

config.rb: config.rb.in
	sed -e s:RUBYC_INCLUDE_DIR:$(rubycincludedir):g \
		-e s:RUBYC_LIB_DIR:$(libdir):g \
		$< > $@

rubyc: rubyc.rb.in
	sed -e s:RUBY_PATH:$(RUBY):g -e s:RUBYC_LIBDIR:$(pkgdatadir):g $< > $@

clean-local:
	rm -f config.rb rubyc
