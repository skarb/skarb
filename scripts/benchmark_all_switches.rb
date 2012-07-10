#!/usr/bin/ruby

PROJECT_DIR = "/home/julek/projects/mgr/"

LegalSwitches = ["--math_inline", "--stack_alloc"]

Dir.chdir(PROJECT_DIR)

0.upto(LegalSwitches.length) do |i|
   LegalSwitches.combination(i) do |c|
      `RUBYC_FLAGS="#{c.join(' ')}" make benchmark > test_results_#{c.join('_')}`
   end
end
