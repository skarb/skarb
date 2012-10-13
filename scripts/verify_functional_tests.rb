#!/usr/bin/env ruby
require 'rspec'

ruby = ARGV.shift || 'ruby'

def extract_expected_output(file)
  lines = File.open(file).readlines
  lines.shift if lines.first =~ /^#!/
  lines.shift if lines.first =~ /^#encoding:/
  lines = lines.take_while{ |line| line =~ /^#/ }
  lines.map { |line| line.sub(/^#/, '') } .join
end

tests = Dir.glob('test/functional/*.rb') .delete_if { |f| f =~ /runner\.rb/ }

describe 'Functional test' do
  tests.each do |file|
    it "#{File.basename file} should be valid in #{ruby}" do
      IO.popen(ruby + ' ' + file + ' 2>&1').read.should ==
        extract_expected_output(file)
    end
  end
end

RSpec::Core::Runner.autorun
