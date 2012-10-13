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

require 'set'

module Mangling
  SpecialCharsConversion = {
    '**' => '__POW__', 
    '+'  => '__PLUS__',
    '-'  => '__MINUS__',
    '*'  => '__MUL__',
    '/'  => '__DIV__',
    '='  => '__EQ__',
    '[]' => '__INDEX__',
    '?'  => '__QMARK',
    '@'  => '__AMP' }

  CKeywords = Set.new [
    :auto,
    :break,
    :case,
    :char,
    :const,
    :continue,
    :default,
    :do,
    :double,
    :else,
    :enum,
    :extern,
    :float,
    :for,
    :goto,
    :if,
    :int,
    :long,
    :register,
    :return,
    :short,
    :signed,
    :sizeof,
    :static,
    :struct,
    :switch,
    :typedef,
    :union,
    :unsigned,
    :void,
    :volatile,
    :while
  ]

  # Returns a mangled function name for a given name, class, and
  # an array of arguments' types.
  def mangle_function_name(name, version, class_name, args_types)
    sname = name.to_s
    SpecialCharsConversion.each_pair do |char, subst|
      sname.gsub! char, subst
    end
    if version == 0
      [class_name.to_s, sname, *args_types].join('_').to_sym
    else
      [class_name.to_s, sname, version, *args_types].join('_').to_sym
    end
  end

  # Returns a name for a function representing class method.
  def mangle_defs_name(name)
    ('s_'+name.to_s).to_sym
  end

  # Returns a name for a global structure containing class variables.
  def mangle_cvars_struct_name(name)
    ('s_'+name.to_s).to_sym
  end

  # Returns a name for instance of a global structure containing class
  # variables.
  def mangle_cvars_struct_var_name(name)
    ('vs_'+name.to_s).to_sym
  end

  # Returns a name for a constant.
  def mangle_const_name(name)
    ('c_'+name.to_s).to_sym
  end

  # Returns a name for a global variable.
  def mangle_gvar_name(name)
    ('g_'+name.rest.to_s).to_sym
  end

  # Returns a name for an instance variable.
  def mangle_ivar_name(name)
    escape_keyword name.rest.to_sym
  end

  # Returns a name for an instance variable.
  def mangle_cvar_name(name)
    escape_keyword name.rest(2).to_sym
  end

  # Returns given name with underscores escaped.
  def escape_name(name)
    escape_keyword name.to_s.gsub('_', '__').to_sym 
  end
  
  # If given name is restricted keyword escapes it with an underscore.
  def escape_keyword(name)
    return ('_'+name.to_s).to_sym if CKeywords.include? name
    name
  end

  alias :mangle_lvar_name :escape_name
end
