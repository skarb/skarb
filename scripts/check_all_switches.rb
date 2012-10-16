#!/usr/bin/ruby

PROJECT_DIR = "/home/julek/projects/mgr/"

LegalSwitches = ["--math_inline", "--stack_alloc", "--object_reuse"]

Dir.chdir(PROJECT_DIR)

0.upto(LegalSwitches.length) do |i|
   LegalSwitches.combination(i) do |c|
      `SKARB_FLAGS="#{c.join(' ')}" make check > check_results_#{c.join('_')}`
   end
end
