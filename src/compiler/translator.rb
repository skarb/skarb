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

require 'sexp_processor'
require 'helpers'
require 'extensions'
require 'sexp_parsing'
require 'translator/symbol_table'
require 'translator/translated_sexp_dictionary'
require 'translator/functions'
require 'translator/flow_control'
require 'translator/local_variables'
require 'translator/instance_variables'
require 'translator/class_variables'
require 'translator/global_variables'
require 'translator/classes'
require 'translator/constants'
require 'translator/argv'
require 'translator/blocks'
require 'translator/mangling'
require 'translator/event_manager'

# Responsible for transforming a Ruby AST to its C equivalent.
# It performs tree traversal by recursive execution of functions
# corresponding to certain nodes types. Each of these functions do
# the following:
# 1. Modifies symbol table
# 2. Returns translated subtree which is valid C AST or nil
# 3. Returns attributes dictionary for the given node
# Final C AST is composed depending on symbol table and subtrees
# returned by subsequent functions.
class Translator
      
  # event -- original sexp type
  # sender -- Translator instance
  EventStruct = Struct.new(:event, :sender, :original_sexp, :translated_sexp)

  def initialize
    @tmp_id_counter = 0
    @symbol_table = SymbolTable.new
    @translated_sexp_dict = TranslatedSexpDictionary.new
    @event_manager = EventManager.new
    [:Object, :Class, MainObject].each {|x| @symbol_table.add_class x }
    @functions_implementations = {}
    @structures_definitions = {}
    @globals = {}
    @user_classes = [MainObject]
    prepare_argv
  end

  def subscribe(event, method)
    @event_manager.subscribe(event, method)
  end

  def subscribe_all(method)
    @event_manager.subscribe_all(method)
  end

  # Analyses a given Ruby AST tree and returns a C AST. Both the argument and
  # the returned value are Sexps from the sexp_processor gem. AST is splitted
  # in 4 sections: structs, prototypes, functions, global variables + main
  def translate(sexp)
    main_block = translate_generic_sexp(sexp)
    main = main_function(SetClassDictionary, CallInitialize, AllocateSelf, ARGVInitialization,
        *lvars_declarations, main_block, CallFinalize, ReturnZero)
    @user_classes.each do |x|
      generate_class_generic_methods x
      generate_class_structure x
      generate_class_static_structure x
    end
    # If there are any functions other than main they have to be included in
    # the output along with their prototypes.
    protos = generate_prototypes
    [s(:file, *@structures_definitions.values, *@globals.values), s(:file, *protos),
      s(:file, *@functions_implementations.values), s(:file, main)]
  end

  # Returns an array with all stmts expanded recursively on all levels.
  def expand_all_stmts(sexps)
     return sexps unless sexps.is_a? Array
    
     expanded_sexps = sexps.class.new 
     sexps.each do |sexp|
        if sexp.is_a? Array
           next if sexp.empty?
           exp_sexp = expand_all_stmts(sexp)
           if sexp.first == :stmts
              expanded_sexps = s(*(expanded_sexps + exp_sexp))
           else
              expanded_sexps << exp_sexp
           end
        else
           next if sexp == :stmts
           expanded_sexps << sexp
        end
     end

     return expanded_sexps.with_value_of(sexps) if sexps.is_a? Sexp
     expanded_sexps
  end

  attr_accessor :symbol_table, :translated_sexp_dict
  attr_reader :tmp_id

  # Each call to this method returns a new, unique var name.
  def next_var_name
    "_var#{@tmp_id_counter += 1}".to_sym
  end

  private

  include Helpers
  include Functions
  include FlowControl
  include LocalVariables
  include InstanceVariables
  include ClassVariables
  include GlobalVariables
  include Classes
  include Constants
  include ARGV
  include Blocks
  include Mangling
  include SexpParsing

  # Name of modified instance of Object class containing main program
  MainObject = :M_Object

  # A sexp representing 'return 0;'
  ReturnZero = s(:return, s(:lit, 0))

  # A sexp setting class dictionary for included library
  SetClassDictionary = s(:stmts, s(:asgn, s(:var, :l_classes_dictionary),
                                     s(:var, :classes_dictionary)))

  # A sexp corresponding to allocation of global variables structure
  AllocateSelf = s(:stmts, s(:decl, :'M_Object', :self_s),
                 s(:asgn, s(:decl, :'Object*', :self),
                   s(:cast, :'Object*', s(:var, :'&self_s'))))

  # A call to the initialize function
  CallInitialize = s(:call, :initialize, s(:args))

  # A call to the finalize function
  CallFinalize = s(:call, :finalize, s(:args))

  # Number of lines in stdlib.rb
  StdlibLineNumber = File.readlines(File.dirname(__FILE__) + '/stdlib.rb').length
 
  # Wraps a given body with a 'main' function. The body is expected to be a
  # collection of Sexp instances.
  def main_function(*body)
    args = s(:abstract_args,
             s(:decl, :int, :argc),
             s(:decl, :'char**', :args))
    s(:defn, :int, :main, args, filtered_block(*body))
  end

  # Calls one of translate_* methods depending on the given sexp's type.
  def translate_generic_sexp(sexp)
    # Notify that the sexp it to be translated.
    event = "#{sexp[0]}_encountered".to_sym
    @event_manager.fire_event(event, EventStruct.new(event, self, sexp, nil))

    # Is there a public or a private method translating such a sexp?
    if respond_to? (method_name = "translate_#{sexp[0]}".to_sym), true
      translated_sexp = send(method_name, sexp)
    else
      line = sexp.line - StdlibLineNumber
      die "Input contains unsupported Ruby instruction in line #{line}. Aborting."
    end
    @translated_sexp_dict.add_entry(sexp, translated_sexp)

    # Notify that the sexp was translated.
    event = "#{sexp[0]}_translated".to_sym
    @event_manager.fire_event(event, EventStruct.new(event, self, sexp, translated_sexp))
    translated_sexp
  end

  # Translates a block of expressions by translating all of them and returning a
  # stmts sexp with a value of the last translated element.
  def translate_block(sexp)
    sexps = sexp.drop(1).map { |s| translate_generic_sexp s }
    filtered_stmts(*sexps).with_value_of sexps.last
  end

  alias :translate_scope :translate_block

  # Returns arguments wrapped in a block sexp.
  def filtered_block(*args)
    #s(:block, *expand_stmts(args))
    s(:block, *args)
  end

  # Returns arguments wrapped in a stmts sexp.
  def filtered_stmts(*args)
    #s(:stmts, *expand_stmts(args))
    s(:stmts, *args)
  end

  # Translates a 'not' or a '!'.
  def translate_not(sexp)
    child = translate_generic_sexp sexp[1]
    filtered_stmts(child).with_value_sexp(
      s(:call, :not, s(:args, child.value_sexp)))
  end

  # Translates a 'nil'.
  def translate_nil(sexp)
    s(:stmts).with_value s(:var, :nil), :NilClass
  end

  # Returns a sexp representing a call to the boolean_value function with a
  # given value.
  def boolean_value(value)
    s(:call, :boolean_value, s(:args, value))
  end
end
