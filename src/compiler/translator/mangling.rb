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

##################################################################################
# (C) 2010-2012 Jan Stępień, Julian Zubek
# 
# This file is a part of Skarb -- Ruby to C compiler.
# 
# Skarb is free software: you can redistribute it and/or modify it under the terms
# of the GNU Lesser General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
# 
# Skarb is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License along
# with Skarb. If not, see <http://www.gnu.org/licenses/>.
# 
##################################################################################
