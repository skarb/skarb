require 'rspec'
require 'fileutils'

rubyc_path = ENV['RUBYC_PATH']
srcdir = ENV['srcdir']
tests = ENV['TESTS'].split.map { |f| srcdir + '/' + f }

def extract_expected_output(file)
  lines = File.open(file).readlines
  lines.shift if lines.first =~ /^#!/
  lines = lines.take_while{ |line| line =~ /^#/ }
  lines.map { |line| line.sub(/^#/, '') } .join
end

describe 'Compiler' do
  tests.each do |file|
    it "should compile #{file}" do
      ARGV.replace [file]
      load rubyc_path
      IO.popen('./a.out').read.should == extract_expected_output(file)
    end
  end

  # After each test remove the binary file.
  after do
    FileUtils.rm_f 'a.out'
  end
end
