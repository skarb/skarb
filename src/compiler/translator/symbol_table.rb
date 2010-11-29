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

  # Adds a new class and generates id for it
  def add_class(class_name)
    self[class_name] ||= { id: next_id }
  end

  # Setter for cclass -- curent class context
  def cclass=(value)
    @cclass = value
    add_class @cclass
    self[@cclass][:functions] ||= {}
    self[@cclass][:ivars] ||= {}
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
  def set_lvar_types(lvar, types)
    lvars_table[lvar][:types] = types
  end

  # Returns the types array for the given local variable in the current function
  # context.
  def get_lvar_types(lvar)
    lvars_table[lvar][:types]
  end

  # Adds an instance variable in the current class context.
  def add_ivar(ivar)
    ivars_table[ivar] ||= {}
  end

  # Checks whether we've got a given instance variable in the current class
  # context.
  def has_ivar?(ivar)
    ivars_table.has_key? ivar
  end

  # Sets the given types array for the given instance variable in the current
  # class context.
  def set_ivar_types(ivar, types)
    ivars_table[ivar][:types] = types
  end

  # Returns the types array for the given instance variable in the current class
  # context.
  def get_ivar_types(ivar)
    ivars_table[ivar][:types]
  end

  private

  # General hash of current class context.
  def class_table
    self[@cclass]
  end

  # The hash of methods in the current class context.
  def functions_table
    self[@cclass][:functions]
  end

  # The hash of instance variables in the current class context.
  def ivars_table
    self[@cclass][:ivars]
  end

  # The hash of local variables in the current function context.
  def lvars_table
    self[@cclass][:functions][@cfunction][:lvars]
  end

  # Each call to this method returns a new, unique id.
  def next_id
    @next_id ||= 0
    @next_id += 1 
  end

end
