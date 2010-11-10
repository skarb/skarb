#!/usr/bin/env ruby
require 'optparse'
require 'ruby_parser'

ARGV.push '-h' if ARGV.empty?

OptionParser.new do |opts|
  opts.banner = "Usage: rubyc [options] input"
  opts.separator "Options:"

  opts.on("-h", "Show this message") do
    puts opts.help
    exit 0
  end
end.parse!

begin
  RubyParser.new.parse(File.read(ARGV.first))
rescue ParseError, SyntaxError
  puts "Input is not correct ruby source. Aborting."
  exit 1
end
