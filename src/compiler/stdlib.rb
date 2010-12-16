class Fixnum < Object
  defined_in_stdlib

  def +
    defined_as :Fixnum__PLUS_
  end

  def -
    defined_as :Fixnum__MINUS_
  end

  def *
    defined_as :Fixnum__MUL_
  end

  def /
    defined_as :Fixnum__DIV_
  end

  def ==
    defined_as :Fixnum__EQ__EQ_
  end

  def <
    defined_as :Fixnum__LT_
  end

  def >
    defined_as :Fixnum__GT_
  end
end

class Float < Object
  defined_in_stdlib

  def +
    defined_as :Float__PLUS_
  end

  def -
    defined_as :Float__MINUS_
  end

  def *
    defined_as :Float__MUL_
  end

  def /
    defined_as :Float__DIV_
  end

  def ==
    defined_as :Float__EQ__EQ_
  end

  def <
    defined_as :Float__LT_
  end

  def >
    defined_as :Float__GT_
  end
end

class String < Object
  defined_in_stdlib

  def +
    defined_as :String__PLUS_
  end

  def *
    defined_as :String__MUL_
  end

  def length
    defined_as :String_length
  end
end

class Array < Object
  defined_in_stdlib

  def []
    defined_as :Array__INDEX_
  end

  def pop
    defined_as :Array_pop
  end

  def push
    defined_as :Array_push
  end

  def shift
    defined_as :Array_shift
  end

  def unshift
    defined_as :Array_unshift
  end

  def delete
    defined_as :Array_delete
  end

  def ==
    defined_as :Array__EQ__EQ_
  end
end

class Hash < Object
  defined_in_stdlib

  def []
    defined_as :Hash__INDEX_
  end

  def []=
    defined_as :Hash__INDEX__EQ_
  end

  def delete
    defined_as :Hash_delete
  end
end
