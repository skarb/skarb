# A following convention is used in class defintions below. A first expression
# in a class declaration should be a call to 'defined_in_stdlib'. Each method
# should specify it's arity by listing it's arguments. Their names doesn't
# matter. Method bodies should begin with a call to 'defined_as' and it's
# argument should be the name of a C function which implements a given method.
# Afterwards it can define it's arguments' types and the type of a returned
# value. If a function returns a Float after being called with an Array and a
# Fixnum arguments a following expression should be added to the method body:
#
#   Float.returned_if Array, Fixnum
#
# If it always returns a certain type, e.g. Fixnum, irrespective of arguments'
# types a following expression is expected:
#
#   returns Fixnum
class Object
  defined_in_stdlib

  def to_s
    defined_as :Object_to__s
    returns String
  end

  # TODO: it should be a static method!
  def puts(what)
    defined_as :Object_puts
    returns NilClass
  end

  # TODO: it should be a static method!
  def rand
    defined_as :Object_rand
    returns Float
  end

  def ==(arg)
    defined_as :Object__EQ__EQ_
  end
end

class Class
  defined_in_stdlib

  @bogus_field  
end

class Fixnum
  defined_in_stdlib

  def +(arg)
    defined_as :Fixnum__PLUS_
    Fixnum.returned_if Fixnum
    Float.returned_if Float
  end

  def -(arg)
    defined_as :Fixnum__MINUS_
    Fixnum.returned_if Fixnum
    Float.returned_if Float
  end

  def *(arg)
    defined_as :Fixnum__MUL_
    Fixnum.returned_if Fixnum
    Float.returned_if Float
  end

  def /(arg)
    defined_as :Fixnum__DIV_
    Fixnum.returned_if Fixnum
    Float.returned_if Float
  end

  def -@(arg)
    defined_as :Fixnum__MINUS_AMP
    returns Fixnum
  end

  def ==(arg)
    defined_as :Fixnum__EQ__EQ_
  end

  def <(arg)
    defined_as :Fixnum__LT_
  end

  def >(arg)
    defined_as :Fixnum__GT_
  end

  def to_s
    defined_as :Fixnum_to__s
    returns String
  end

  def zero?
    defined_as :Fixnum_zero_QMARK
  end

  def times
    defined_as :Fixnum_times
  end

  def upto(arg)
    defined_as :Fixnum_upto
  end
end

class Float
  defined_in_stdlib

  def +(arg)
    defined_as :Float__PLUS_
    returns Float
  end

  def -(arg)
    defined_as :Float__MINUS_
    returns Float
  end

  def *(arg)
    defined_as :Float__MUL_
    returns Float
  end

  def /(arg)
    defined_as :Float__DIV_
    returns Float
  end

  def ==(arg)
    defined_as :Float__EQ__EQ_
  end

  def <(arg)
    defined_as :Float__LT_
  end

  def >(arg)
    defined_as :Float__GT_
  end

  def to_s
    defined_as :Float_to__s
    returns String
  end

  def zero?
    defined_as :Float_zero_QMARK
  end

  def floor
    defined_as :Float_floor
  end
end

class String
  defined_in_stdlib

  def +(arg)
    defined_as :String__PLUS_
    returns String
  end

  def *(arg)
    defined_as :String__MUL_
    returns String
  end

  def length
    defined_as :String_length
    returns Fixnum
  end

  def to_s
    defined_as :String_to__s
    returns String
  end

  def to_i
    defined_as :String_to__i
    returns Fixnum
  end

  def to_f
    defined_as :String_to__f
    returns Float
  end

  def [](index)
    defined_as :String__INDEX_
  end

  def empty?
    defined_as :String_empty__QMARK__
  end

  def ==(other)
    defined_as :String__EQ__EQ_
  end
end

class NilClass
  defined_in_stdlib

  def to_s
    defined_as :Nil_to__s
    returns String
  end
end

class Array
  defined_in_stdlib

  def [](arg)
    defined_as :Array__INDEX_
  end

  def []=(idx, val)
    defined_as :Array__INDEX__EQ_
  end

  def pop
    defined_as :Array_pop
  end

  def push(arg)
    defined_as :Array_push
    returns Array
  end

  def shift
    defined_as :Array_shift
  end

  def unshift(arg)
    defined_as :Array_unshift
    returns Array
  end

  def delete(arg)
    defined_as :Array_delete
  end

  def ==(arg)
    defined_as :Array__EQ__EQ_
  end

  def length
    defined_as :Array_length
    returns Fixnum
  end

  def join(sep)
    defined_as :Array_join
    returns String
  end

  def map
    defined_as :Array_map
    returns Array
  end
end

class Hash
  defined_in_stdlib

  def [](arg)
    defined_as :Hash__INDEX_
  end

  def []=(key, val)
    defined_as :Hash__INDEX__EQ_
  end

  def delete(arg)
    defined_as :Hash_delete
  end

  def keys
    defined_as :Hash_keys
    returns Array
  end
end

class TrueClass
  defined_in_stdlib

  def to_s
    defined_as :True_to__s
    returns String
  end
end

class FalseClass
  defined_in_stdlib

  def to_s
    defined_as :False_to__s
    returns String
  end
end
