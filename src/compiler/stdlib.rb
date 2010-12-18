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
    defined_as :Object_to_s
  end

  # TODO: it should be a static method!
  def puts(what)
    defined_as :Object_puts
  end
end

class Fixnum < Object
  defined_in_stdlib

  def +(arg)
    defined_as :Fixnum__PLUS_
  end

  def -(arg)
    defined_as :Fixnum__MINUS_
  end

  def *(arg)
    defined_as :Fixnum__MUL_
  end

  def /(arg)
    defined_as :Fixnum__DIV_
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
    defined_as :Fixnum_to_s
  end
end

class Float < Object
  defined_in_stdlib

  def +(arg)
    defined_as :Float__PLUS_
  end

  def -(arg)
    defined_as :Float__MINUS_
  end

  def *(arg)
    defined_as :Float__MUL_
  end

  def /(arg)
    defined_as :Float__DIV_
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
    defined_as :Float_to_s
  end
end

class String < Object
  defined_in_stdlib

  def +(arg)
    defined_as :String__PLUS_
  end

  def *(arg)
    defined_as :String__MUL_
  end

  def length
    defined_as :String_length
  end

  def to_s
    defined_as :String_to_s
  end
end

class Array < Object
  defined_in_stdlib

  def [](arg)
    defined_as :Array__INDEX_
  end

  def pop
    defined_as :Array_pop
  end

  def push(arg)
    defined_as :Array_push
  end

  def shift
    defined_as :Array_shift
  end

  def unshift(arg)
    defined_as :Array_unshift
  end

  def delete(arg)
    defined_as :Array_delete
  end

  def ==(arg)
    defined_as :Array__EQ__EQ_
  end
end

class Hash < Object
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
end
