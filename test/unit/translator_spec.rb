require 'rspec'
require 'ruby_parser'
require 'sexp_processor'
require 'translator'
require 'optimizations/math_inliner'

describe Translator do
  before do
    @translator = Translator.new
    @rp = RubyParser.new
    @stdlib_declarations = File.open('/home/julek/projects/mgr/src/compiler/stdlib.rb').read
  end

  # FIXME: Temporal solution
  StandardClasses = [ :Object, :Class, :M_Object ]

  # Parses given Ruby code and passes it to the Translator.
  def translate_code(code)
    @translator.expand_all_stmts(@translator.translate(@rp.parse(code)))
  end

  def translate_code_only(code)
    @translator.expand_all_stmts(@translator.send(:translate_generic_sexp, @rp.parse(code)))
  end

  # Returns a sexp representing a whole C program with a given body of the
  # 'main' function.
  def program(*body)
    [s(:file, struct_M_Object, struct_sM_Object, cARGV, struct_sM_Object_decl),
     s(:file), s(:file), s(:file, main(*body))]
  end

  # A sexp defining the main object with given fields' declarations.
  def struct_M_Object(*fields_declarations)
      s(:typedef, s(:struct, nil,
        s(:block, s(:decl, :Object, :parent),
        *fields_declarations)), :'M_Object')
  end

  # A sexp defining the main object class with given fields' declarations.
  def struct_sM_Object(*fields_declarations)
      s(:typedef, s(:struct, nil,
        s(:block, s(:decl, :Class, :meta))), :'s_M_Object')
  end

  # A sexp defining the cARGV constant.
  def cARGV
    s(:decl, :"Object*", :'c_ARGV')
  end

  # A sexp defining the main object class structure initialization.
  def struct_sM_Object_decl(*fields_declarations)
      s(:asgn, s(:decl, :'s_M_Object', :'vs_M_Object'),
        s(:init_block,
          s(:init_block,
            s(:init_block, s(:lit, 2)),
            s(:init_block, s(:lit, 1)))))
  end

  # Returns a sexp representing a 'main' function with a given body.
  def main(*body)
    args = s(:abstract_args,
             s(:decl, :int, :argc),
             s(:decl, :'char**', :args))
    s(:defn, :int, :main, args,
      s(:block,
       s(:asgn, s(:var, :l_classes_dictionary), s(:var, :classes_dictionary)),
       s(:call, :initialize, s(:args)),
       s(:decl, :'M_Object', :self_s),
       s(:asgn, s(:decl, :'Object*', :self),
         s(:cast, :'Object*', s(:var, :'&self_s'))),
       s(:call, :prepare_argv,
         s(:args,
           s(:l_unary_oper, :&, s(:var, :'c_ARGV')),
           s(:var, :argc),
           s(:var, :args))),
       *body,
       s(:call, :finalize, s(:args)),
       s(:return, s(:lit, 0))))
  end

  # Returns a sexp representing a call to the Fixnum_new function with a given
  # int value.
  def fixnum_new(value)
    s(:call, :Fixnum_new, s(:args, s(:lit, value)))
  end

  # Returns a sexp representing a call to the boolean_value function with a
  # given value.
  def boolean_value(value)
    s(:call, :boolean_value, s(:args, value))
  end

  # Returns a sexp representing a declaration of a pointer to Object.
  def decl(name)
    s(:decl, :'Object*', name)
  end

#  it 'should translate lit' do
#    translate_code('69').should == program
#  end
#
#  it 'should translate if' do
#    translate_code('if 1; 2 end').should ==
#      program(decl(:'_var1'),
#              s(:if,
#                boolean_value(fixnum_new(1)),
#                s(:block, s(:asgn, s(:var, :'_var1'), fixnum_new(2)))))
#  end
#
#  it 'should translate block' do
#    translate_code('4 if 3; 6 if 1;').should ==
#      program(decl(:'_var1'),
#              s(:if, boolean_value(fixnum_new(3)),
#                s(:block, s(:asgn, s(:var, :'_var1'), fixnum_new(4)))),
#              decl(:'_var2'),
#              s(:if, boolean_value(fixnum_new(1)),
#                s(:block, s(:asgn, s(:var, :'_var2'), fixnum_new(6)))))
#  end

#  it 'should translate unless' do
#    translate_code('unless 1; 2 end').should ==
#      program(decl(:'_var1'),
#             s(:if,
#               boolean_value(s(:call , :not, s(:args, fixnum_new(1)))),
#               s(:block, s(:asgn, s(:var, :'_var1'), fixnum_new(2)))))
#  end

#  it 'should translate if else' do
#    translate_code('if 1; 2 else 3 end').should ==
#      program(decl(:'_var1'),
#           s(:if,
#             boolean_value(fixnum_new(1)),
#             s(:block, s(:asgn, s(:var, :'_var1'), fixnum_new(2))),
#             s(:block, s(:asgn, s(:var, :'_var1'), fixnum_new(3)))))
#  end

#  it 'should translate if elsif' do
#    translate_code('if 1; 2 elsif 5; 3 end').should ==
#      program(decl(:'_var1'),
#              s(:if,
#                boolean_value(fixnum_new(1)),
#                s(:block, s(:asgn, s(:var, :'_var1'), fixnum_new(2))),
#                s(:block,
#                  decl(:'_var2'),
#                  s(:if,
#                    boolean_value(fixnum_new(5)),
#                    s(:block, s(:asgn, s(:var, :'_var2'), fixnum_new(3)))
#                   ), s(:asgn, s(:var, :'_var1'), s(:var, :'_var2')))))
#  end

#  it 'should translate if elsif not' do
#    translate_code('if 1; 2 elsif not 5; 3 end').should ==
#      program(decl(:'_var1'),
#              s(:if,
#                boolean_value(fixnum_new(1)),
#                s(:block, s(:asgn, s(:var, :'_var1'), fixnum_new(2))),
#                s(:block,
#                  decl(:'_var2'),
#                  s(:if,
#                    boolean_value(s(:call, :not, s(:args, fixnum_new(5)))),
#                    s(:block, s(:asgn, s(:var, :'_var2'), fixnum_new(3)))
#                   ), s(:asgn, s(:var, :'_var1'), s(:var, :'_var2')))))
#  end

#  it 'should translate while' do
#    translate_code('while 1; 2 end').should ==
#      program(
#        s(:while, boolean_value(fixnum_new(1)),
#          s(:block,     
#             s(:while, s(:lit, 1),
#                s(:block,
#                  s(:if, s(:l_unary_oper, :!,
#                           boolean_value(fixnum_new(1))), s(:break)))), s(:break))))
#  end

#  it 'should translate until' do
#    translate_code('until 1; 2 end').should ==
#      program(
#        s(:while, s(:l_unary_oper, :!, boolean_value(fixnum_new(1))),
#          s(:block,     
#             s(:while, s(:lit, 1),
#                s(:block,
#                  s(:if, boolean_value(fixnum_new(1)), s(:break)))), s(:break))))
#  end

  it 'should detect type of fixnum literal' do
    translate_code_only('2').value_type.should == :Fixnum
  end

  it 'should detect type of float literal' do
    translate_code_only('2.5').value_type.should == :Float
  end

  it 'should detect type of variable' do
    translate_code_only('b=2')
    translate_code_only('b').value_type.should == :Fixnum
  end

  it 'should detect type of a function call returning a constant' do
    translate_code_only('def fun(x); 5.3; end')
    translate_code_only('fun()').value_type.should == :Float
  end

  it 'should detect type of a function call returning an argument' do
    translate_code_only('def fun(x); return x; end')
    translate_code_only('fun(3.3)').value_type.should == :Float
    translate_code_only('fun(2)').value_type.should == :Fixnum
  end

  it 'should detect self type' do
    translate_code_only('class A; def a; self; end; end; a = A.new')
    translate_code_only('a.a').value_type.should == :A
  end

  it 'should detect self type with return' do
    translate_code_only('class A; def a; return self; end; end; a = A.new')
    translate_code_only('a.a').value_type.should == :A
  end

  it 'should detect empty return' do
    translate_code_only('class A; def a; return; end; end; a = A.new')
    translate_code_only('a.a').value_type.should == :nil
  end

  it 'should recognize nested call with known types' do
    translate_code_only('class A; def a; self; end; def p=(v); @p=v; end; end; a = A.new')
    translate_code_only('a.a.p=1').join.should_not include "find_method"
  end

#  it 'should translate local assignment to new variable' do
#    translate_code('b=2').should ==
#      program(decl(:b), s(:asgn, s(:var, :b), fixnum_new(2)))
#  end

#  it 'should translate a function without arguments' do
#    translate_code('def fun; 5; end; fun')[1..3].should ==
#      [s(:file,
#        s(:static,
#          s(:prototype, :'Object*', :"M_Object_fun", s(:args, decl(:self))))),
#        s(:file,
#          s(:static,
#            s(:defn, :'Object*', :"M_Object_fun", s(:args, decl(:self)),
#              s(:block, s(:return, fixnum_new(5)))))),
#        s(:file,
#        main(
#          s(:call, :clear_cache, s(:args)),
#          s(:asgn,
#                  s(:decl, :int, :'_var1'),
#                  s(:call, :"M_Object_hash",
#                    s(:args, s(:str, "fun"), s(:lit, 3)))),
#                s(:asgn,
#                  s(:binary_oper, :'.',
#                    s(:indexer,
#                      s(:var, :"M_Object_words"), s(:var, :'_var1')),
#                    s(:var, :function)),
#                  s(:l_unary_oper, :'&', s(:var, :"M_Object_fun"))),
#                s(:asgn,
#                  s(:binary_oper, :'.',
#                    s(:indexer,
#                      s(:var, :"M_Object_words"), s(:var, :'_var1')),
#                    s(:var, :wrapper)),
#                  s(:l_unary_oper, :'&', s(:var, :"wrapper_1"))),
#          decl(:'_var2'),
#          s(:asgn, s(:var, :'_var2'), s(:call, :"M_Object_fun", s(:args, s(:var, :self))))))]
#  end
#
#  it 'should translate a function without arguments called twice' do
#    translate_code('def fun; 5; end; fun; fun')[1..3].should ==
#      [s(:file,
#        s(:static,
#          s(:prototype, :'Object*', :"M_Object_fun", s(:args, decl(:self))))),
#        s(:file,
#        s(:static,
#          s(:defn, :'Object*', :"M_Object_fun", s(:args, decl(:self)),
#            s(:block, s(:return, fixnum_new(5)))))),
#        s(:file,
#        main(
#          s(:call, :clear_cache, s(:args)),
#          s(:asgn,
#                  s(:decl, :int, :'_var1'),
#                  s(:call, :"M_Object_hash",
#                    s(:args, s(:str, "fun"), s(:lit, 3)))),
#                s(:asgn,
#                  s(:binary_oper, :'.',
#                    s(:indexer,
#                      s(:var, :"M_Object_words"), s(:var, :'_var1')),
#                    s(:var, :function)),
#                  s(:l_unary_oper, :'&', s(:var, :"M_Object_fun"))),
#                s(:asgn,
#                  s(:binary_oper, :'.',
#                    s(:indexer,
#                      s(:var, :"M_Object_words"), s(:var, :'_var1')),
#                    s(:var, :wrapper)),
#                  s(:l_unary_oper, :'&', s(:var, :"wrapper_1"))),
#          decl(:'_var2'),
#          s(:asgn, s(:var, :'_var2'), s(:call, :"M_Object_fun", s(:args, s(:var, :self)))),
#          decl(:'_var3'),
#          s(:asgn, s(:var, :'_var3'), s(:call, :"M_Object_fun", s(:args, s(:var, :self))))))]
#  end
#
  it 'should translate an assignment to an instance variable' do
    translate_code('@a=@a')[1..3].should ==
      [s(:file), s(:file), s(:file,
        main(s(:asgn, s(:binary_oper, :'->', s(:cast, :'M_Object*', s(:var, :self)), s(:var, :a)),
                s(:binary_oper, :'->', s(:cast, :'M_Object*', s(:var, :self)), s(:var, :a)))))]
  end

  it 'should not translate an unsupported construction' do
    $stdout = StringIO.new
    expect do
      translate_code('begin; puts 1; rescue; puts 2; end')
    end .to raise_error SystemExit
    $stdout = STDOUT
  end

  it 'should not translate an undefined local variable' do
    expect do
      translate_code('puts oh_my_goodness_what_is_that')
    end .to raise_error SystemExit
  end

  it 'should not translate an undefined function' do
    expect do
      translate_code('there_is_no_such_function(4)')
    end .to raise_error SystemExit
  end

  it 'should not translate a constructor of an undefined class' do
    expect do
      translate_code('x = WhatMightThisBe.new')
    end .to raise_error SystemExit
  end

#  it 'should translate a function with arguments' do
#    args = s(:args, decl(:self), decl(:x))
#    translate_code('def fun(x); x; end; fun 3')[1..3].should ==
#      [s(:file,
#        s(:static,
#          s(:prototype, :'Object*', :"M_Object_fun_Fixnum", args)),
#        s(:static,
#          s(:prototype, :'Object*', :"M_Object_fun_", args))),
#       s(:file,
#        s(:static,
#          s(:defn, :'Object*', :"M_Object_fun_Fixnum", args,
#            s(:block, s(:return, s(:var, :x))))),
#        s(:static,
#          s(:defn, :'Object*', :"M_Object_fun_", args,
#            s(:block, s(:return, s(:var, :x)))))),
#        s(:file,
#        main(
#          s(:call, :clear_cache, s(:args)),
#          s(:asgn,
#                  s(:decl, :int, :'_var1'),
#                  s(:call, :"M_Object_hash",
#                    s(:args, s(:str, "fun"), s(:lit, 3)))),
#                s(:asgn,
#                  s(:binary_oper, :'.',
#                    s(:indexer,
#                      s(:var, :"M_Object_words"), s(:var, :'_var1')),
#                    s(:var, :function)),
#                  s(:l_unary_oper, :'&', s(:var, :"M_Object_fun_"))),
#                s(:asgn,
#                  s(:binary_oper, :'.',
#                    s(:indexer,
#                      s(:var, :"M_Object_words"), s(:var, :'_var1')),
#                    s(:var, :wrapper)),
#                  s(:l_unary_oper, :'&', s(:var, :"wrapper_2"))),
#          decl(:'_var2'),
#          s(:asgn, s(:var, :'_var2'), s(:call, :"M_Object_fun_Fixnum",
#                                     s(:args, s(:var, :self), fixnum_new(3))))))]
#  end

#  it 'should translate class declaration' do
#    translate_code('class A; def initialize(a); @a=a; end; end; A.new(1)').should ==
#    [s(:file, struct_M_Object, struct_sM_Object,
#        s(:typedef,
#          s(:struct, nil,
#            s(:block, s(:decl, :Object, :parent), decl(:a))), :A),
#        s(:typedef,
#          s(:struct, nil,
#            s(:block, s(:decl, :Class, :meta))), :s_A),
#        cARGV,
#        struct_sM_Object_decl,
#        s(:asgn, s(:decl, :s_A, :vs_A),
#          s(:init_block,
#          s(:init_block,
#            s(:init_block, s(:lit, 2)),
#            s(:init_block, s(:lit, 3)))))),
 #       s(:file,
 #         s(:static, s(:prototype, :"Object*", :A_0_main, s(:args))),
 #         s(:static,
 #           s(:prototype, :'Object*', :A_initialize_Fixnum,
 #             s(:args, decl(:self), decl(:a)))),
 #             s(:static,
 #               s(:prototype, :'Object*', :A_new_Fixnum, s(:args, decl(:a)))),
#
  #              s(:static,
 #                 s(:prototype, :'Object*', :A_initialize_,
#                    s(:args, decl(:self), decl(:a))))),
#      s(:file,
 #       s(:static,
  #      s(:defn,
   #       :"Object*",
    #     :A_0_main,
     #    s(:args),
      #   s(:block,
    #      s(:decl, :A, :self_s),
    #      s(:asgn,
    #       s(:decl, :"Object*", :self),
    #       s(:cast, :"Object*", s(:var, :"&self_s"))),
    #      s(:call, :clear_cache, s(:args)),
    #      s(:asgn,
    #       s(:decl, :int, :'_var1'),
    #       s(:call, :A_hash, s(:args, s(:str, "initialize"), s(:lit, 10)))),
     #     s(:asgn,
     #      s(:binary_oper,
     #       :".",
     #       s(:indexer, s(:var, :A_words), s(:var, :'_var1')),
     #       s(:var, :function)),
     #      s(:l_unary_oper, :&, s(:var, :A_initialize_))),
     #     s(:asgn,
     #      s(:binary_oper,
     #       :".",
      #      s(:indexer, s(:var, :A_words), s(:var, :'_var1')),
       #     s(:var, :wrapper)),
        #   s(:l_unary_oper, :&, s(:var, :wrapper_2))),
         # s(:return, s(:var, :nil))))),
       # s(:static,
       #   s(:defn, :'Object*', :A_initialize_Fixnum, s(:args, decl(:self), decl(:a)),
       #     s(:block,
       #       s(:asgn,
       #          s(:binary_oper, :'->', s(:cast, :'A*', s(:var, :self)), s(:var, :a)), s(:var, :a)),
        #      s(:return, s(:binary_oper, :'->', s(:cast, :'A*', s(:var, :self)), s(:var, :a)))))),
      #  s(:static,
      #    s(:defn, :'Object*', :A_new_Fixnum, s(:args, decl(:a)),
       #     s(:block,
        #      s(:asgn, decl(:self),
         #       s(:call, :xmalloc,
          #        s(:args, s(:call, :sizeof, s(:args, s(:lit, :A)))))),
           #   s(:asgn,
           #     s(:binary_oper, :'->', s(:var, :self), s(:var, :type)), s(:lit, 3)),
           #       s(:call, :A_initialize_Fixnum, s(:args, s(:var, :self), s(:var, :a))),
            #  s(:return, s(:var, :self))))),
  #      s(:static,
   #       s(:defn, :'Object*', :A_initialize_, s(:args, decl(:self), decl(:a)),
   #         s(:block,
   #           s(:asgn,
   #              s(:binary_oper, :'->', s(:cast, :'A*', s(:var, :self)), s(:var, :a)), s(:var, :a)),
    #          s(:return, s(:binary_oper, :'->', s(:cast, :'A*', s(:var, :self)), s(:var, :a))))))),
    #  s(:file,
     #   main(
     #    decl(:'_var2'),
    #     s(:asgn, s(:var, :'_var2'), s(:call, :A_0_main, s(:args))),
   #      decl(:'_var3'),
   #      s(:asgn, s(:var, :'_var3'),
    #     s(:call, :'A_new_Fixnum', s(:args, fixnum_new(1))))))]
 # end

 # it 'should put variables declaration at the beggining of a function' do
 #   translate_code('b = 0; a = if b; a = 1; b = 2; end;').should ==
 #     program(decl(:b),decl(:a),s(:asgn, s(:var, :b), fixnum_new(0)),
 #             decl(:'_var1'),
 #             s(:if, boolean_value(s(:var, :b)),
 #               s(:block,
 #                 s(:asgn, s(:var, :a), fixnum_new(1)),
 #                 s(:asgn, s(:var, :b), fixnum_new(2)),
 #                 s(:asgn, s(:var, :'_var1'), s(:var, :b)))),
 #             s(:asgn, s(:var, :a), s(:var, :'_var1')))
 # end

  it 'should remember type within a conditional block -- there should
  be no call_method call' do
    translate_code("class A; def foo; end; end; if 1; a = A.new; a.foo; end")
      .join.should_not include "call_method"
  end

  it 'should use atomic xmalloc when appropriate' do
    translate_code(@stdlib_declarations + "2").join.should include "xmalloc_atomic"
  end

  it 'should discover return type of recursive call' do
    translate_code("class A; def foo; end; end;
                        def rec; if 1; rec; else; A.new; end; end;
                        rec.foo").join.should_not include "call_method"
  end

  it 'should build translation dictionary' do
    translate_code("a=2")
    @translator.translated_sexp_dict.should include :lasgn 
  end

  it 'should inline arithmetical expressions' do
   MathInliner.new(@translator)
   translate_code(@stdlib_declarations + "a = 1 + 1").join.should_not include "Fixnum__PLUS"
  end
end
