SUBDIRS = emitter translator optimizations
nodist_bin_SCRIPTS = skarb
nodist_pkgdata_DATA = config.rb
dist_pkgdata_DATA = compiler.rb emitter.rb helpers.rb parser.rb translator.rb \
                    extensions.rb manager.rb stdlib.rb classes_dict_builder.rb\
		    hash_builder.rb optimizer.rb sexp_parsing.rb
dist_noinst_DATA = skarb.rb.in config.rb.in

config.rb: config.rb.in
	sed -e s:SKARB_INCLUDE_DIR:$(skarbincludedir):g \
		-e s:SKARB_LIB_DIR:$(libdir):g \
		$< > $@

skarb: skarb.rb.in
	sed -e s:RUBY_PATH:$(RUBY):g -e s:SKARB_LIBDIR:$(pkgdatadir):g $< > $@

clean-local:
	rm -f config.rb skarb
