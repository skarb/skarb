require 'rspec'
require 'fileutils'
require 'benchmark'

RUBYC_PATH = ENV['RUBYC_PATH']
RUBY = ENV['RUBY']
SRCDIR = ENV['srcdir']
TESTS = ENV['TESTS'].split.map { |f| SRCDIR + '/' + f }
CFLAGS = "CFLAGS='-O3 -funroll-loops #{ENV['CFLAGS']}'"

def benchmark
  Benchmark.measure { 3.times { yield } } .real
end

describe 'Compiler' do
  TESTS.each do |file|
    it "should pass #{file}" do
      # Compile the test file, run it in MRI, run the compiled version and
      # compare the results.
      `#{CFLAGS} #{RUBY} -I#{SRCDIR}/../../src/compiler #{RUBYC_PATH} #{file}`
      mri = benchmark { `#{RUBY} #{file}` }
      rubyc = benchmark { `./a.out` }
      mri.should > rubyc
    end
  end

  # After each test remove the binary file.
  after do
    FileUtils.rm_f 'a.out'
  end
end
