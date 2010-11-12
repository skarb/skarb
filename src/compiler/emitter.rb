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
class Emitter

  MinimalCode = "int main(){return 0;}"
  
  def emit(sexp)
    return MinimalCode if sexp == nil
    @out = StringIO.new
    emit_generic_elem(sexp)
    return @out.string
  end

  # Universal function for emitting any argument expression
  # with correct parenthesis
  def emit_arg_expr(elem)
    case elem[0]
    when :str, :lit, :var
      emit_generic_elem(elem)
    else
      @out << "("
      emit_generic_elem(elem)
      @out << ")"
    end
  end

  # Emits symbol or executes method "emit_..." according sexp[0] symbol
  def emit_generic_elem(sexp)
    if sexp.class==Symbol
      @out << sexp
    elsif sexp.class==Sexp
      begin
        emit_method=method("emit_"+sexp[0].to_s)
        emit_method.call(sexp)
      rescue NameError
        @out << sexp[0]
        sexp.rest.each do |elem|
          @out << " "
          emit_generic_elem(elem)
        end
      end 
    end  
  end

  
  # Macro directives
  # - :include
  # - :define

  def emit_include(sexp)
    @out << "#include " << sexp[1]
  end

  def emit_define(sexp)
    @out << "#define " << sexp[1]
  end


  # Blocks
  # - :subblock -- multiple lines ended by ";"
  # - :block -- "{" + subblock + "}"

  def emit_block(sexp)
    @out << "{\n"
    emit_subblock(sexp)
    @out << "}\n"
  end

  def emit_subblock(sexp)
    sexp.rest.each do |elem|
      case elem[0]
      when :define, :include, :defn
        emit_generic_elem(elem)
      else
        emit_generic_elem(elem)
        @out << ";\n"
      end
    end
  end


  # Literals and vars
  # - :lit -- literal
  # - :str -- string literal
  # - :var -- reference to variable
  # - :decl -- variable declaration, two child nodes: type and name
 
  def emit_str(sexp)
    @out << '"' << sexp[1] << '"'
  end

  def emit_lit(sexp)
    @out << sexp[1]
  end
 
  def emit_var(sexp)
    @out << sexp[1]
  end

  def emit_decl(sexp)
    @out << sexp[1] << " " << sexp[2]
  end


  # Assignments
  # - :asgn -- normal assignment
  # - :aasgn -- "*=", "-=", "/=", "+="
  
  def emit_asgn(sexp)
    emit_arg_expr(sexp[1])
    @out << " = "
    emit_arg_expr(sexp[2])
  end

  def emit_aasgn(sexp)
    emit_arg_expr(sexp[2])
    @out << " " << sexp[1] << " "
    emit_arg_expr(sexp[3])
  end


  # Functions definitions and calls
  # - :prototype -- function prototype
  # - :defn -- function definition
  # - :call -- function call
  # - :abstract_args -- abstract parameters list
  # - :actual_args -- actual parameters list

  def emit_prototype(sexp)
    @out << sexp[1] << " " << sexp[2] << " ("
    emit_abstract_args(sexp[3])
    @out << ")"
  end
 
  def emit_abstract_args(sexp)
    sexp.middle.each do |x|
      emit_generic_elem(x)
      @out << ", "
    end
    if sexp.last!=nil
      emit_generic_elem(sexp.last)
    end
  end

  def emit_defn(sexp)
    @out << sexp[1] << " " << sexp[2] << "("
    emit_abstract_args(sexp[3])
    @out << ")\n"
    emit_generic_elem(sexp[4])
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


  # Flow control
  # - :if -- three child nodes: condition (:arg_expr), block (:block), "else" block (:block)
  # - :for -- four child nodes: init (:arg_expr), condition (:arg_expr),
  #   assignment (:arg_expr), code (:block)
  # - :while -- two child nodes: condition (:arg_expr), code (:block)
  # - :do -- two child nodes: condition (:arg_expr), code (:block)
  # - :switch -- two child nodes: expression (:arg_expr), code (:block)
  # - :case
  # - :goto
  # - :label -- goto label
  # - :break
  # - :continue
  # - :return
  # - :default

  def emit_if(sexp)
    @out << "if ("
    emit_arg_expr(sexp[1])
    @out << ")\n"
    emit_generic_elem(sexp[2])
    unless sexp[3]==nil
      @out << "else\n"
      emit_generic_elem(sexp[3])
    end
  end

  def emit_while(sexp)
    @out << "while ("
    emit_arg_expr(sexp[1])
    @out << ")\n"
    emit_generic_elem(sexp[2])
    @out << "\n"
  end

  def emit_do(sexp)
    @out << "do\n"
    emit_generic_elem(sexp[2])
    @out << "\n"
    @out << "while ("
    emit_arg_expr(sexp[1])
    @out << ");\n"
  end

  def emit_for(sexp)
    @out << "for ("
    emit_generic_elem(sexp[1])
    @out << "; "
    emit_generic_elem(sexp[2])
    @out << "; "
    emit_generic_elem(sexp[3])
    @out << ")\n"
    emit_generic_elem(sexp[4])
  end

  def emit_switch(sexp)
    @out << "switch ("
    emit_generic_elem(sexp[1])
    @out << ")\n"
    emit_generic_elem(sexp[2])
  end

  def emit_default(sexp)
    @out << "default: "
  end

  def emit_case(sexp)
    @out << "case "
    emit_generic_elem(sexp[1])
    @out << ": "
  end

  def emit_label(sexp)
    emit_generic_elem(sexp[1])
    @out << ": "
  end 


  # Operators
  # - :binary_oper -- arithmetic, bitwise, logical, "." or "->" operator
  # - :short_if -- "?:" operator
  # - :l_unary_oper -- left "++", "--", "-", "!", "*", "&" operator
  # - :r_unary_oper -- right "++", "--" operator

  def emit_short_if(sexp)
    emit_arg_expr(sexp[1])
    @out << " ? "
    emit_arg_expr(sexp[2])
    @out << " : "
    emit_arg_expr(sexp[3])
  end

  def emit_binary_oper(sexp)
    emit_arg_expr(sexp[2])
    @out << " " << sexp[1] << " "
    emit_arg_expr(sexp[3])
  end

  def emit_l_unary_oper(sexp)
    @out << sexp[1]
    emit_arg_expr(sexp[2])
  end

  def emit_r_unary_oper(sexp)
    emit_arg_expr(sexp[2])
    @out << sexp[1]
  end


  # == Composite types
  # - :typedef
  # - :enum
  # - :union
  # - :struct

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

end
