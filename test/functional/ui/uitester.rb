require 'rspec'

compiler = ARGV.shift

def extract_expected_output(file)
  lines = File.open(file).readlines
  lines.shift if lines.first =~ /^#!/
  lines = lines.take_while{ |line| line =~ /^#/ }
  lines.map { |line| line.sub(/^#/, '') } .join
end

describe 'UI' do
  Dir.glob('*.sh').reject { |f| f == 'testlib.sh' } .each do |file|
    it "should pass #{file}" do
      output = IO.popen("sed -e 's,rubyc,#{compiler},g' #{file} | sh").read
      output.should == extract_expected_output(file)
    end
  end
end
