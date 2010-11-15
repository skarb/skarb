require 'simplecov'

module SimpleCov::Configuration
  # We don't want coverage_path to use the root path. Compare with
  # https://github.com/colszowka/simplecov/blob/v0.3.7/lib/simplecov/configuration.rb#L36
  def coverage_path
    coverage_path = coverage_dir
    FileUtils.mkdir_p coverage_path
    coverage_path
  end
end

SimpleCov.start do
  add_filter "/unit/"
  coverage_dir ENV['builddir'] + '/coverage'
  root ENV['top_srcdir']
end

# Running unit tests
Dir.glob(ENV['srcdir'] + '/unit/*_spec.rb').each { |file| require file }

# Running functional tests
ENV['TESTS'] = Dir.glob(ENV['srcdir'] + '/functional/*.rb') \
  .delete_if { |f| f =~ /runner\.rb/ } .map { |f| File.basename f } .join ' '
functional_tests_runner = ENV['srcdir'] + '/functional/runner.rb'
ENV['srcdir'] += '/functional'
load functional_tests_runner
