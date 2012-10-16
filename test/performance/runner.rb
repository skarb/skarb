require 'rspec'
require 'fileutils'
require 'benchmark'

SKARB_PATH = ENV['SKARB_PATH']
SKARB_FLAGS = ENV['SKARB_FLAGS']
RUBY = ENV['RUBY']
SRCDIR = ENV['srcdir']
TESTS = ENV['TESTS'].split.map { |f| SRCDIR + '/' + f }
CFLAGS = "CFLAGS='-O3 -funroll-loops #{ENV['CFLAGS']}'"

def benchmark
  5.times.map do
    Benchmark.measure do
      yield
      raise 'Child process died' unless $?.exitstatus.zero?
    end .real
  end .sort[1..-2].reduce(:+)
end

describe 'Compiler' do
   TESTS.each do |file|
    it "should pass #{file}" do
      # Compile the test file, run it in MRI, run the compiled version and
      # compare the results.
      `#{CFLAGS} #{RUBY} -I#{SRCDIR}/../../src/compiler #{SKARB_PATH} #{SKARB_FLAGS} #{file}`
      mri = benchmark { `#{RUBY} #{file}` }
      skarb = benchmark { `./a.out` }
      puts file
      puts "mri: #{mri}"
      puts "skarb: #{skarb}"
      mri.should > skarb
    end
  end

  # After each test remove the binary file.
  after do
    FileUtils.rm_f 'a.out'
  end
end
