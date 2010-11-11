require 'stringio'

class Array
	def middle(a=1, b=-1)
		return self[a..self.length+b-1]
	end

	def rest(index=1)
		return self[index..self.length-1] if index >= 0
		return self[0, self.length+index]
	end
end

class Emitter

	def emit_br(sexp)
		@out << "\n"
	end

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
		emit_arg_elem(sexp[1])
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
		emit_arg_elem(sexp[1])
		@out << " || "
		emit_arg_elem(sexp[2])
	end

	def emit_and(sexp)
		emit_arg_elem(sexp[1])
		@out << " && "
		emit_arg_elem(sexp[2])
	end

	def emit_not(sexp)
		@out << "!("
		emit_arg_elem(sexp[1])
		@out << ")"
	end

	def emit_short_if(sexp)
		emit_arg_elem(sexp[1])
		@out << " ? "
		emit_arg_elem(sexp[2])
		@out << " : "
		emit_arg_elem(sexp[3])
	end

	def emit_args(sexp)
		sexp.middle.each { |x| @out << x.first << " " << x.last << ", " }
		if sexp.last!=nil
			@out << sexp.last.first << " " << sexp.last.last
		end
	end

	def emit_while(sexp)
		if sexp[3]
			@out << "while ("
			emit_arg_elem(sexp[1])
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
			emit_arg_elem(sexp[1])
			@out << ");\n"
		end
	end

	def emit_defn(sexp)
		@out << sexp[1] << " " << sexp[2] << "("
		emit_args(sexp[3])
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
		emit_arg_elem(sexp[1])
		@out << ";\n"
	end

	def emit_arg_elem(elem)
		case elem[0]
		when :call
			@out << "("
			emit_call(elem)
			@out << ")"
		when :lasgn
			@out << "("
			emit_lasgn(elem)
			@out << ")"
		when :iasgn
			@out << "("
			emit_iasgn(elem)
			@out << ")"
		when :oper
			@out << "("
			emit_oper(elem)
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

	def emit_arglist(sexp)
		return if sexp.last == nil

		sexp.middle(1,-1).each do |elem|
			emit_arg_elem(elem)
			@out << ", "
		end
		emit_arg_elem(sexp.last)
	end

	def emit_call(sexp)
		@out << sexp[1] << "("
		emit_arglist(sexp[2])
		@out << ")"
	end

	def emit_cdecl(sexp)
		@out << "#define " << sexp[1] << " "
		#to do
		@out << sexp[2] << "\n"
	end

	def emit_int(sexp)
		@out << "int " << sexp[1] << ";\n"
	end

	def emit_str(sexp)
		@out << "str " << sexp[1] << ";\n"
	end

	def emit_include(sexp)
		@out << "#include " << sexp[1] << "\n"
	end

	def emit_lasgn(sexp)
		@out << sexp[1] << " = "
		emit_arg_elem(sexp[2])
	end

	def emit_iasgn(sexp)
		@out << sexp[1] << "->" << sexp[2] << " = "
		emit_arg_elem(sexp[3])
	end

	def emit_oper(sexp)
		emit_arg_elem(sexp[1])
		@out << " " << sexp[2] << " "
		emit_arg_elem(sexp[3])
	end

	def emit_generic_elem(sexp)
		begin
			emit_method=method("emit_"+sexp[0].to_s)
			emit_method.call(sexp)
		rescue NameError
			raise "Invalid tree node"
		end
	end

	def emit_block(sexp)
		sexp.rest.each do |elem|
			next if elem==nil
			case elem[0]
			when :call
				emit_call(elem)
				@out << ";\n"
			when :lasgn
				emit_lasgn(elem)
				@out << ";\n"
			when :iasgn
				emit_iasgn(elem)
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
