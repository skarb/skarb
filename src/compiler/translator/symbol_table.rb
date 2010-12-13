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
    @function_name2id = {}
    self.cclass = Translator::MainObject
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
    self[@cclass][:functions_def] ||= {}
    self[@cclass][:ivars] ||= {}
  end

  # Sets the parent class for a given symbol. Both args are symbols.
  def set_parent(child, parent)
    # Begin with checking whether we know both classes.
    [child, parent].each { |cls| raise "Unknown class: #{cls}" if !self[cls] }
    # The parent cannot be re-set.
    raise "There's already a parent for #{child}" if self[child][:parent]
    self[child][:parent] = parent
  end

  # Gets the parent class for a given symbol with a class name.
  def parent(child)
    self[child][:parent]
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

  # Executes a block in a given class context and resets the current class
  # to the previous value.
  def in_class(name)
    raise 'Block expected' unless block_given?
    prev_class = cclass
    self.cclass = name
    retval = yield
    self.cclass = prev_class
    retval
  end

  # Adds function in the current class context
  def add_function(fun, sexp)
    self[@cclass][:functions_def][fun] = sexp
    @function_name2id[fun] ||= next_id 
  end

  # Check if function with given name is defined for current class
  def has_function?(name)
    self[@cclass][:functions_def].has_key? name 
  end

  # Adds a local variable in the current function context and sets its kind
  # as default (:local)
  def add_lvar(lvar)
    lvars_table[lvar] ||= {}
    lvars_table[lvar][:kind] = :local
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

  # Marks the given local variable in the current function context as one
  # of given type (:local or :param)
  def set_lvar_kind(lvar, kind)
    lvars_table[lvar][:kind] = kind
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

  # The hash of local variables in the current function context.
  def lvars_table
    self[@cclass][:functions][@cfunction][:lvars]
  end

  private
  
  # The hash of methods in the current class context.
  def functions_table
    self[@cclass][:functions]
  end
  
  # Each call to this method returns a new, unique id.
  def next_id
    @next_id ||= 0
    @next_id += 1
  end

end
