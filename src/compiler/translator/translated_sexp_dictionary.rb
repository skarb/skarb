require 'sexp_processor'

# Pair containing Ruby sexps and it translated C equivalent.
SexpPair = Struct.new(:ruby_sexp, :c_sexp)

# This class registers relation between parts of original Ruby AST and its translated
# C equivalent. Such knowledge is necessary for further optimisations. Dictionary is
# indexed by Ruby sexp types. Each entry is an array containing pairs of sexps
# (SexpPair).
class TranslatedSexpDictionary < Hash

   def add_entry(ruby_sexp, c_sexp)
     (self[ruby_sexp.first] ||= []).push SexpPair.new(ruby_sexp, c_sexp)
   end

end
