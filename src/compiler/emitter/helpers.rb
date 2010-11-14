# Helpers outputting commonly used characters or constructions.
module Emitter::Helpers
  # Runs a given block enclosing it's output in parenthesis.
  def in_parentheses
    left_parenthesis
    yield
    right_parenthesis
  end

  # Adds '(' to the output.
  def left_parenthesis
    @out << '('
  end

  # Adds ')' to the output.
  def right_parenthesis
    @out << ')'
  end

  # Adds a given string to the output enclosed in spaces.
  def output_with_spaces(str)
    space
    @out << str
    space
  end

  # Adds a double quotation mark to the output.
  def space
    @out << ' '
  end

  # Adds a given string to the output enclosed in double quotes.
  def output_with_double_quotes(str)
    double_quote
    @out << str
    double_quote
  end

  # Adds a double quotation mark to the output.
  def double_quote
    @out << '"'
  end

  # Adds a comma to the output.
  def comma
    @out << ','
  end

  # Adds a semicolon to the output.
  def semicolon
    @out << ';'
  end

  # Adds a colon to the output.
  def colon
    @out << ':'
  end

  # Emits the sexp's type and its elements separated with spaces.
  def output_type_and_children(sexp)
    @out << sexp[0]
    sexp.rest.each do |elem|
      space
      emit_generic_elem elem
    end
  end
end