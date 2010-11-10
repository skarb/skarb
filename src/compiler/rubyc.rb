#!/usr/bin/env ruby
require 'optparse'
require 'compiler'
require 'emitter'
require 'translator'
require 'parser'

ARGV.push '-h' if ARGV.empty?

OptionParser.new do |opts|
  opts.banner = "Usage: rubyc [options] input"
  opts.separator "Options:"

  opts.on("-h", "Show this message") do
    puts opts.help
    exit 0
  end
end.parse!

input = if ARGV[0] == '-'
          STDIN
        else
          File.open ARGV.pop
        end

Compiler.new.compile(Emitter.new.emit(
  Translator.new.translate(Parser.new.parse(input))))
