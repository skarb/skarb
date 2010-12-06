# Symbol table is a dictionary consisting of pairs:
# "symbol" - "attributes".
# "attributes" is another dictionary consisting of entries:
# "attribute name" - "attribute value"
#
# Symbol tables are nested in each other:
# Classes --> Functions --> Local variables
class SymbolTable < Hash
  attr_reader :cclass, :cfunction

  def initialize
    self.cclass = :Object
    self.cfunction = :_main
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

  # Executes a block in a given function context and resets the current function
  # to the previous value. A funny fact: it won't work without those two self
  # references used below. Seems like a Ruby's bug. Or a feature.
  def in_function(name)
    raise 'Block expected' unless block_given?
    prev_function = cfunction
    self.cfunction = name
    retval = yield
    self.cfunction = prev_function
    retval
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

  # Sets the given type for the given local variable in the current function
  # context.
  def set_lvar_type(lvar, type)
    lvars_table[lvar][:type] = type
  end

  # Returns the type for the given local variable in the current function
  # context.
  def get_lvar_type(lvar)
    lvars_table[lvar][:type]
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

  # Sets the given type for the given instance variable in the current class
  # context.
  def set_ivar_type(ivar, type)
    ivars_table[ivar][:type] = type
  end

  # Returns the type for the given instance variable in the current class
  # context.
  def get_ivar_type(ivar)
    ivars_table[ivar][:type]
  end

  # Setter for higher class
  def higher_class=(class_name)
    class_table[:higher_class]=class_name
  end

  # Getter for higher class
  def higher_class
    class_table[:higher_class]
  end

  # The hash of instance variables in the current class context.
  def ivars_table
    self[@cclass][:ivars]
  end

  # General hash of current class context.
  def class_table
    self[@cclass]
  end

  private

  # The hash of methods in the current class context.
  def functions_table
    self[@cclass][:functions]
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
