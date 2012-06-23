RSPEC = rspec
TESTS_ENVIRONMENT = $(RSPEC) -c -I$(top_srcdir)/src/compiler
TESTS = emitter_spec.rb translator_spec.rb array_spec.rb local_table_spec.rb \
	connection_graph_builder_spec.rb translation_streamer_spec.rb \
	stdlib_graphs_loader_spec.rb
dist_noinst_DATA = $(TESTS)
