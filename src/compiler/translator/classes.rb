require 'translator/stdlib_classes'

class Translator
  # A module consisting of functions which handle translation of nodes related
  # to classes.
  module Classes
    include StdLibClasses

    # Translates class definition.
    def translate_class(sexp)
      class_name=sexp[1]
      @symbol_table.add_class sexp[1]
      if declared_as_defined_in_stdlib? sexp
        load_stdlib_class sexp
        s()
      else
        body = s() 
        @symbol_table.in_class class_name do
          set_parent sexp if sexp[2]
          body = translate_generic_sexp(sexp[3])
        end
        @user_classes << class_name
        build_main_function(class_name, body)
      end
    end

    # Translates self reference into empty sexp with value
    def translate_self(sexp)
      cclass = @symbol_table.cclass
      return @symbol_table.value_of cclass if @symbol_table.cfunction == :_main
      s().with_value s(:var, :self), cclass
    end

    private

    # Sets the parent-child class relationship in the symbol table.
    def set_parent(sexp)
      raise 'Only constant inheritance is allowed' if sexp[2][0] != :const
      @symbol_table.set_parent sexp[1], sexp[2][1]
    end

    # Generates a structure for instance fields after
    # all the methods were translated.
    def generate_class_structure(class_name)
      parent_class = @symbol_table.parent class_name
      ivars_table = @symbol_table.ivars_table class_name
      iclass = class_name
      while iclass = @symbol_table.parent(iclass)
        ivars_table = ivars_table.merge @symbol_table.ivars_table(iclass)
      end
      ifields_declarations =
        ivars_table.keys.map { |key| s(:decl, :'Object*', mangle_ivar_name(key)) }
      structure_definition =
        s(:typedef, s(:struct, nil,
                      s(:block, s(:decl, :Object, :parent),                        
                        *ifields_declarations)), class_name)
      @structures_definitions[class_name] = structure_definition
    end

    # Generates a structure for class fields
    def generate_class_static_structure(class_name)
      parent_class = @symbol_table.parent class_name
      cvars_table = @symbol_table.cvars_table class_name
      cfields_declarations =
        cvars_table.keys.map { |key| s(:decl, :'Object*', mangle_cvar_name(key)) }
      scname = mangle_cvars_struct_name class_name
      scvar = mangle_cvars_struct_var_name class_name
      cstructure_definition =
        s(:typedef, s(:struct, nil,
                      s(:block, s(:decl, :Class, :meta),
                        *cfields_declarations)), scname)
      @structures_definitions[scname] = cstructure_definition
      @globals[scvar] = s(:asgn, s(:decl, scname, scvar),
                          s(:init_block,
                            s(:init_block,
                              s(:init_block,
                                s(:lit, @symbol_table.id_of(:Class))),
                              s(:init_block,
                                s(:lit, @symbol_table.id_of(class_name))))))
    end

    # Generates generic versions of class methods
    def generate_class_generic_methods(cname)
      @symbol_table.in_class cname do
        chash = @symbol_table.class_table
        if chash.has_key? :functions_def
          chash[:functions_def].each do |fname,farray|
            farray.each_index do |version|
              args_number = farray[version][2].rest.length
              # We have to count in 'self' argument
              implement_generic_function(fname, farray[version], version, cname) 
            end
          end
        end
      end
    end

    # Implements function with generic arguments 
    def implement_generic_function(fname, fdef, version, cname)
      types = fdef[2].rest.map { nil }
      impl_name = mangle_function_name(fname, version, cname, types)
      unless function_implemented? impl_name
        implement_function impl_name, fdef, types
      end
    end

    # Returns C code allocating new object of given class and storing pointer
    # in given variable.
    def class_constructor(class_name, var)
       alloc_function = :xmalloc
       if @symbol_table.has_key? class_name
          # We know legal class id.
          s_type = s(:asgn,
                     s(:binary_oper, :'->', s(:var, var), s(:var, :type)),
                     s(:lit, @symbol_table.id_of(class_name)))
          if @symbol_table.class_atomic_alloc? class_name
             alloc_function = :xmalloc_atomic
          end
       else
          # We assume that the class is defined in C file and will be included
          # later on.
          s_type = s(:call, :set_type, s(:args, s(:var, var), s(:var, class_name)))
       end
       
       s(:stmts,
          s(:decl, :'Object*', var),
          s(:asgn, s(:var, var),
            s(:call, alloc_function,
              s(:args, s(:call, :sizeof, s(:args, s(:lit, class_name)))))),
          s_type)
    end
  
    # Puts main function for class in @functions_implementations and returns
    # sexp calling it.
    def build_main_function(class_name, body)
      return s() if body.nil? or body.length < 2
      var = next_var_name
      v = 0
      fname = ([class_name, v, "main"].join '_').to_sym
      #TODO: Find a more elegant way to do it
      while @functions_implementations.has_key? fname
        v += 1
        fname = ([class_name, v, "main"].join '_').to_sym
      end
      body_block =
        filtered_block(
          *lvars_declarations,
          s(:decl, class_name, :self_s),
          s(:asgn,
            s(:decl, :'Object*', :self),
            s(:cast, :'Object*', s(:var, :'&self_s'))), body,
          s(:return, body.value_sexp))
      @functions_implementations[fname] =
        s(:static, s(:defn, :'Object*', fname, s(:args), body_block)).
        with_value_type body.value_type
      filtered_stmts(
        s(:decl, :'Object*', var),
        s(:asgn, s(:var, var), s(:call, fname, s(:args))
       )).with_value s(:var, var), body.value_type
    end
  end
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
