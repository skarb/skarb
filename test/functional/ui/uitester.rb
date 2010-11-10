require 'rspec'

compiler = ENV['RUBYC']
srcdir = ENV['srcdir']
tests = ENV['TESTS'].split.map { |f| srcdir + '/' + f }

def extract_expected_output(file)
  lines = File.open(file).readlines
  lines.shift if lines.first =~ /^#!/
  lines = lines.take_while{ |line| line =~ /^#/ }
  lines.map { |line| line.sub(/^#/, '') } .join
end

describe 'UI' do
  tests.each do |file|
    it "should pass #{file}" do
      output = IO.popen("sed -e 's,rubyc,#{compiler},g' #{file} | sh").read
      output.should == extract_expected_output(file)
    end
  end
end
