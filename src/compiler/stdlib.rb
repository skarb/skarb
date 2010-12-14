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
