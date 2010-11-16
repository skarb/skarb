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

  # Adds a local variable in the current function context.
  def add_lvar(lvar)
    lvars_table[lvar] ||= {}
  end

  # Checks whether we've got a given local variable in the current function
  # context.
  def has_lvar?(lvar)
    lvars_table.has_key? lvar
  end

  # Sets the given types array for the given local variable in the current
  # function context.
  def set_type(lvar, types)
    lvars_table[lvar][:types] = types
  end

  # Returns the types array for the given local variable in the current function
  # context.
  def lvars_types(lvar)
    lvars_table[lvar][:types]
  end

  private

  # The hash of local variables in the current function context.
  def lvars_table
    self[@cclass][:functions][@cfunction][:lvars]
  end
end
