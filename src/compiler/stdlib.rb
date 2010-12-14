class Object
  defined_in_stdlib

  def to_s
    defined_as :Object_to_s
  end
end

class Fixnum < Object
  defined_in_stdlib

  def +
    defined_as :Fixnum__PLUS_
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

  def to_s
    defined_as :Fixnum_to_s
  end
end
