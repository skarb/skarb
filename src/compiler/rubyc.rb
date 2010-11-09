#!/usr/bin/env ruby
require 'optparse'

ARGV.push '-h' if ARGV.empty?

OptionParser.new do |opts|
  opts.banner = "Usage: rubyc [options] input"
  opts.separator "Options:"

  opts.on("-h", "Show this message") do
    puts opts.help
    exit 0
  end
end.parse!
