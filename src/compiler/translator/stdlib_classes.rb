class Translator
  # A module handling translation of classes defined in the standard library in
  # C. This module should be included in the Translator::Class module in order
  # to provide set_parent. FIXME: isn't this in fact a bad practice?
  module StdLibClasses
    # Returns true if the class definition begins with a call to
    # defined_in_stdlib method. The sexp is checked for a following structure:
    #   s(:class, :ClassName, s(:const, :Parent),
    #     s(:scope,
    #       s(:block,
    #         s(:call, nil, :defined_in_stdlib, s(:arglist)), ...
    def declared_as_defined_in_stdlib?(sexp)
      begin
        call = sexp[3][1][1]
        call[0] == :call and call[1].nil? and call[2] = :defined_in_stdlib
      rescue NoMethodError
        false
      end
    end

    # Adds an stdlib class declared in a given sexp to the symbol table.
    def load_stdlib_class(sexp)
      raise 'Not an stdlib class' unless declared_as_defined_in_stdlib? sexp
      @symbol_table.in_class sexp[1] do
        @symbol_table.class_defined_in_stdlib
        set_parent sexp if sexp[2]
        load_methods sexp
      end
    end

    private

    # Loads all methods declared in a stdlib class declaration and puts them in
    # the symbol table.sugin load_methods.
    def load_methods(sexp)
      sexp[3][1].rest.select { |child| child.first == :defn } .each do |defn|
        if not stdlib_method? defn
          raise "#{@symbol_table.cclass}.#{defn[1]} isn't a stdlib method"
        end
        @symbol_table.add_function defn[1], s(:stdlib_defn, fun_name(defn), defn[2])
      end
    end

    # Returns true if the method body begins with a call to a defined_as
    # function and the first argument is a symbol.
    def stdlib_method?(defn)
      call = defn[3][1][1]
      call.first == :call and call[1].nil? and call[2] == :defined_as and
      (arg = call[3][1])[0] == :lit and arg[1].is_a? Symbol
    end

    # A symbol being the first argument of a first method call in the method
    # body. It is assumed that stdlib_method? would return true for the defn
    # sexp passed to this function.
    def fun_name(defn)
      # The ultimate masterpiece of illegible code.
      defn[3][1][1][3][1][1]
    end
  end
end
