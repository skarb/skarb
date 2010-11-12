require 'stringio'

# Extensions for standard Array class
class Array

  # Returns a slice from the middle of the array
  # - a -- index of first char of the slice
  # - b -- negative index of last char of the slice
  def middle(a=1, b=-1)
    return self[a..self.length+b-1]
  end

  # Returns fragment from supplied index to the end of the array
  def rest(index=1)
    return self[index..self.length-1] if index >= 0
    return self[0, self.length+index]
  end

end

# Generates code from given C abstract syntax tree. It does
# not perform any validation.
#
# == Modifiers
# Modifiers encapsulate variables definitions, they can be nested in
# each other.
# - :unsigned
# - :signed
# - :const
# - :volatile
# - :static
# - :auto
# - :extern
# - :register
#
# == Flow control
# - :if -- three child nodes: condition (:arg_expr), block (:block), "else" block (:block)
# - :for -- four child nodes: init (:arg_expr), condition (:arg_expr),
#   assignment (:arg_expr), code (:block)
# - :while -- two child nodes: condition (:arg_expr), code (:block)
# - :do -- two child nodes: condition (:arg_expr), code (:block)
# - :switch -- two child nodes: expression (:arg_expr), code (:block)
# - :case
# - :goto
# - :break
# - :continue
# - :return
# - :default
#
# == Operators
# - :binary_oper -- arithmetic, bitwise or logical operator
# - :short_if -- "?:" operator
# - :l_unary_oper -- left incrementation, decrementation and unary minus operator
# - :r_unary_oper -- right incrementation and decrementation operator
#
# == Types
# - :void
# - :char
# - :short
# - :int
# - :long
# - :float
# - :double
# - :ctype -- custom type declared with typedef
#
# - :typedef
# - :enum
# - :union
# - :struct -- structure definition
# - :prototype -- function prototype
#
# - :var
# - :svar_fld -- reference to field of a struct
# - :svar_fld_ptr -- reference to field of a struct via pointer
#
# - :asgn -- assignment
# - :call -- function call
# - :defn -- function definition
# - :abstract_args -- abstract parameters list
# - :actual_args -- actual parameters list
#
# - :scope -- lexical scope of a function
# - :block -- block of code consisting of multiple lines terminated by ';'

class Emitter

  def emit_struct(sexp)
    @out << "typedef struct\n"
    @out << "{\n"
    sexp.rest(2).each { |elem| emit_generic_elem(elem) }
    @out << "} " << sexp[1] << ";\n"
  end

  def emit_prototype(sexp)
    @out << sexp[1] << " " << sexp[2] << " ("
    sexp[3].middle.each { |type| @out << type << ", " }
    @out << sexp[3].last << ");\n"
  end

  def emit_if(sexp)
    @out << "if ("
    emit_arg_expr(sexp[1])
    @out << ") "
    if sexp[2]==:block
      @out << "\n{\n"
      emit_generic_elem(sexp[2])
      @out << "}\n"
    else
      emit_generic_elem(sexp[2])
      @out << ";\n"
    end
    unless sexp[3]==nil
      @out << "else "
      if sexp[3]==:block
        @out << "\n{\n"
        emit_generic_elem(sexp[3])
        @out << "}\n"
      else
        emit_generic_elem(sexp[3])
        @out << ";\n"
      end
    end
  end

  def emit_or(sexp)
    emit_arg_expr(sexp[1])
    @out << " || "
    emit_arg_expr(sexp[2])
  end

  def emit_and(sexp)
    emit_arg_expr(sexp[1])
    @out << " && "
    emit_arg_expr(sexp[2])
  end

  def emit_not(sexp)
    @out << "!("
    emit_arg_expr(sexp[1])
    @out << ")"
  end

  def emit_short_if(sexp)
    emit_arg_expr(sexp[1])
    @out << " ? "
    emit_arg_expr(sexp[2])
    @out << " : "
    emit_arg_expr(sexp[3])
  end

  def emit_abstract_args(sexp)
    sexp.middle.each { |x| @out << x.first << " " << x.last << ", " }
    if sexp.last!=nil
      @out << sexp.last.first << " " << sexp.last.last
    end
  end

  def emit_while(sexp)
    if sexp[3]
      @out << "while ("
      emit_arg_expr(sexp[1])
      @out << ")\n"
      @out << "{\n"
      emit_generic_elem(sexp[2])
      @out << "}\n"
    else
      @out << "do\n"
      @out << "{\n"
      emit_generic_elem(sexp[2])
      @out << "}\n"
      @out << "while ("
      emit_arg_expr(sexp[1])
      @out << ");\n"
    end
  end

  def emit_defn(sexp)
    @out << sexp[1] << " " << sexp[2] << "("
    emit_abstract_args(sexp[3])
    @out << ")\n"
    emit_scope(sexp[4])
  end

  def emit_scope(sexp)
    @out << "{\n"
    sexp[1, sexp.length-1].each { |x| emit_block(x) }
    @out << "}\n"
  end

  def emit_return(sexp)
    @out << "return "
    emit_arg_expr(sexp[1])
    @out << ";\n"
  end

  # Universal function for emitting any argument expression
  # with correct parenthesis
  def emit_arg_expr(elem)
    case elem[0]
    when :call
      @out << "("
      emit_call(elem)
      @out << ")"
    when :asgn
      @out << "("
      emit_asgn(elem)
      @out << ")"
    when :binary_oper
      @out << "("
      emit_binary_oper(elem)
      @out << ")"
    when :if
      @out << "("
      emit_short_if(elem)
      @out << ")"
    when :or
      @out << "("
      emit_or(elem)
      @out << ")"
    when :and
      @out << "("
      emit_and(elem)
      @out << ")"
    when :not
      emit_not(elem)
    when :str
      @out << '"' << elem[1] << '"'
    when :lit
      @out << elem[1]
    when :lvar
      @out << elem[1]
    when :ivar
      @out << elem[1] << "->" << elem[2]
    end
  end

  def emit_actual_args(sexp)
    return if sexp.last == nil

    sexp.middle(1,-1).each do |elem|
      emit_arg_expr(elem)
      @out << ", "
    end
    emit_arg_expr(sexp.last)
  end

  def emit_call(sexp)
    @out << sexp[1] << "("
    emit_actual_args(sexp[2])
    @out << ")"
  end

  def emit_define(sexp)
    @out << "#define " << sexp[1] << " "
    # TODO
    @out << sexp[2] << "\n"
  end

  def emit_int(sexp)
    @out << "int " << sexp[1]
  end

  def emit_include(sexp)
    @out << "#include " << sexp[1] << "\n"
  end

  def emit_asgn(sexp)
    @out << sexp[1] << " = "
    emit_arg_expr(sexp[2])
  end

  def emit_struct_field(sexp)
    @out << sexp[1] << "." << sexp[2]
  end

  def emit_ptr_struct_field(sexp)
    @out << sexp[1] << "->" << sexp[2]
  end

  def emit_binary_oper(sexp)
    emit_arg_expr(sexp[1])
    @out << " " << sexp[2] << " "
    emit_arg_expr(sexp[3])
  end

  def emit_l_unary_oper(sexp)
    @out << sexp[1]
    emit_arg_expr(sexp[2])
  end

  def emit_r_unary_oper(sexp)
    emit_arg_expr(sexp[1])
    @out << sexp[2]
  end

  # Executes method "emit_..." according to sexp[0] symbol
  def emit_generic_elem(sexp)
    begin
      emit_method=method("emit_"+sexp[0].to_s)
      emit_method.call(sexp)
    rescue NameError
      raise "Invalid tree node: "+sexp[0].to_s
    end
  end

  def emit_block(sexp)
    sexp.rest.each do |elem|
      next if elem==nil
      case elem[0]
      when :call
        emit_call(elem)
        @out << ";\n"
      when :asgn
        emit_asgn(elem)
        @out << ";\n"
      else
        emit_generic_elem(elem)
      end
    end
  end

  MinimalCode = "int main(){return 0;}"

  def emit(sexp)
    return MinimalCode if sexp == nil
    @out = StringIO.new
    emit_generic_elem(sexp)
    return @out.string
  end
end
