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
