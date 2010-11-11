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

Dir.glob(ENV['srcdir'] + '/unit/*_spec.rb').each { |file| require file }
