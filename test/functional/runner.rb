require 'rspec'
require 'fileutils'

rubyc_path = ENV['RUBYC_PATH']
rubyc_flags = ENV['RUBYC_FLAGS'] ? ENV['RUBYC_FLAGS'].split : []
srcdir = ENV['srcdir']
tests = ENV['TESTS'].split.map { |f| srcdir + '/' + f }

def extract_expected_output(file)
  lines = File.open(file).readlines
  lines.shift if lines.first =~ /^#!/
  lines.shift if lines.first =~ /^#encoding:/
  lines = lines.take_while{ |line| line =~ /^#/ }
  lines.map { |line| line.sub(/^#/, '') } .join
end

describe 'Compiler' do
  tests.each do |file|
    it "should compile #{file}" do
      ARGV.replace(rubyc_flags + [file])
      load rubyc_path
      IO.popen('./a.out 2>&1').read.should == extract_expected_output(file)
    end
  end

  # After each test remove the binary file.
  after do
    FileUtils.rm_f %w/a.out output.c/
  end
end
