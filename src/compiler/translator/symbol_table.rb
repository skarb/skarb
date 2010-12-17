# Symbol table is a dictionary consisting of pairs:
# "symbol" - "attributes".
# "attributes" is another dictionary consisting of entries:
# "attribute name" - "attribute value"
#
# Symbol tables are nested in each other:
# Classes --> Functions --> Local variables
class SymbolTable < Hash
  attr_reader :cclass, :cfunction, :cblock

  def initialize
    self.add_class(:Object)
    self.cclass = Translator::MainObject
    self.cfunction = :_main
    @fname2id = {}
  end

  # Adds a new class and generates id for it
  def add_class(class_name)
    self[class_name] ||= { id: next_id, parent: :Object }
  end

  # Setter for cclass -- curent class context
  def cclass=(value)
    @cclass = value
    add_class @cclass
    self[@cclass][:functions] ||= {}
    self[@cclass][:functions_def] ||= {}
    self[@cclass][:ivars] ||= {}
    self[@cclass][:defined_in_stdlib] ||= false
  end

  # Sets the parent class for a given symbol. Both args are symbols.
  def set_parent(child, parent)
    # Begin with checking whether we know both classes.
    [child, parent].each { |cls| raise "Unknown class: #{cls}" if !self[cls] }
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
    @cfunction = prev_function
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

  # Executes a block in a given block context and resets the context
  # to the previous value.
  # TODO: Shall block be merely an identifier or more complex structure?
  # Perhabs this method should perform certain action after exiting from
  # the block.
  def in_block(name)
    raise 'Block expected' unless block_given?
    prev_block = @cblock
    @cblock = name
    retval = yield
    @cblock = prev_block
    retval
  end

  # Adds function in the current class context
  def add_function(fun, sexp)
    self[@cclass][:functions_def][fun] = sexp
    @fname2id[fun] ||= fnext_id
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

  # Saves an information that the current class has been defined in the standard
  # library.
  def class_defined_in_stdlib
    class_table[:defined_in_stdlib] = true
  end

  # True if a given class has been defined in the standard library. If no class
  # name is given the current class is taken as a default.
  def class_defined_in_stdlib?(class_name=@cclass)
    self[class_name][:defined_in_stdlib]
  end

  # Returns ID of function name. IDs are guaranted to be unique. Methods with
  # same names defined in different classes share the same ID.
  def fname_id(fname)
    @fname2id[fname] ||= fnext_id
  end

  private
  
  # The hash of methods in the current class context.
  def functions_table
    self[@cclass][:functions]
  end
  
  # Each call to this method returns a new, unique id.
  def next_id
    @next_id ||= -1
    @next_id += 1
  end

  # Each call to this method returns a new, unique id.
  def fnext_id
    @fnext_id ||= -1
    @fnext_id += 1
  end
end
