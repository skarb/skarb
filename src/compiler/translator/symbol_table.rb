# Symbol table is a dictionary consisting of pairs:
# "symbol" - "attributes".
# "attributes" is another dictionary consisting of entries:
# "attribute name" - "attribute value"
#
# Symbol tables are nested in each other:
# Classes --> Functions --> Local variables
class SymbolTable < Hash
  def initialize
    cclass = Object
    cfunction = :_main
  end

  # Setter for cclass -- curent class context
  def cclass=(value)
    @cclass = value
    self[@cclass] ||= {}
    self[@cclass][:functions] ||= {}
  end

  # Setter for cfunction -- current function context
  def cfunction=(value)
    @cfunction = value
    self[@cclass][:functions][@cfunction] ||= {}
    self[@cclass][:functions][@cfunction][:lvars] ||= {}
  end

  def add_lvar(lvar)
    lvars_table[lvar] ||= {}
  end

  def cclass_attrs
    self[@cclass]
  end

  def functions_table
    self[@cclass][:functions]
  end

  def cfunction_attrs
    self[@cclass][:functions][@cfunction]
  end

  def lvars_table
    self[@cclass][:functions][@cfunction][:lvars]
  end
end
