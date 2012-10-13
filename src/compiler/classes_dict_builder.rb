# Copyright (c) 2010-2012 Jan Stępień, Julian Zubek
#
# This file is a part of Skarb -- a Ruby to C compiler.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'hash_builder'

# This class contains tools used to construct C static structures for storing
# information about classes -- their methods, static fields etc.
class ClassesDictionaryBuilder
  # Constructor. Whole functionality of ClassesDictionaryBuilder relies
  # on final symbol table. 
  def initialize(symbol_table)
    @symbol_table = symbol_table
  end

  # Generates full code for classes dictionary. Returns code splitted
  # in structs, prototypes, methods and global variables + main
  def emit_classes_dictionary
    methods = emit_methods_arrays
    [nil, nil, methods, emit_dict_init]
  end

  private  

  HashElemStruct = "hash_elem"

  # Generates definition of class dictionary and initializes it with
  # values from @symbol_table.
  def emit_dict_init
    selector = lambda { |k,v| v.has_key? :id }
    sorter = lambda { |x,y| x[1][:id] <=> y[1][:id] }
    mapper = lambda do |k|
      if k[1][:parent].nil?
        parent_id = -1
      else
        parent_id = @symbol_table.id_of k[1][:parent]
      end
      if k[1][:functions_def].nil? or k[1][:functions_def].empty?
        msearch = s(:lit, :NULL)
      else
        msearch = s(:var, ('&'+k[0].to_s+"_method_find").to_sym)
      end
      cvars = s(:var, ('&vs_'+k[0].to_s).to_sym)
      s(:init_block, s(:lit, parent_id),
        msearch, cvars)
    end
    elem_inits = @symbol_table.select(&selector).each.sort(&sorter).map(&mapper)
    Emitter.emit(s(:file, s(:asgn, s(:decl, :dict_elem, :'classes_dictionary[]'),
                            s(:init_block, *elem_inits))))
  end

  # Generates class methods hashes.
  def emit_methods_arrays
    @symbol_table.map do |cname, chash|
      if chash.has_key? :functions_def
        id2fun_records = chash[:functions_def].map do |fname,farray|
          fdef = farray.first
          args_number = fdef[2].rest.length
          if fdef[0] == :stdlib_defn
            # Method defined in stdlib
            [fname, ('&'+fdef[1].to_s).to_sym, :NULL]
          else
            # Method defined in user code
            [fname, :NULL, :NULL]
          end 
        end
        HashBuilder.emit_table(cname, HashElemStruct, id2fun_records)
      end
    end.join
  end

end
