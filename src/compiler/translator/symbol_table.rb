require 'helpers'

# Symbol table is a dictionary consisting of pairs:
# "symbol" - "attributes".
# "attributes" is another dictionary consisting of entries:
# "attribute name" - "attribute value"
#
# Symbol tables are nested in each other:
# Classes --> Functions --> Local variables
#
# Local variables table is a head of conditional blocks hierarchy.
# Each block contains all the variables from it descendent.
# Variables which type is set within block are declared as of unknown
# type in parent block.
class SymbolTable < Hash
  include Helpers

  attr_reader :cclass, :cfunction, :cblock

  def initialize
    self.cclass = :Object
    class_table[:parent] = nil
    self.cclass = Translator::MainObject
    self.cfunction = :_main
    @cblock = self[@cclass][:functions][@cfunction]
    @fname2id = {}
  end

  # Adds a new constant and generates id for it.
  def add_constant(name, value)
    self[name] ||= { }
    self[name][:value] = value
    self[name][:type] = :const
  end 

  # Adds a new class, generates id for it and initializes mandatory
  # keys if default values.
  def add_class(class_name)
    self[class_name] ||= { }
    if self[class_name][:type] == :const
      die "#{class_name} is not a class"
    end
    if self[class_name][:id].nil?
      self[class_name][:id] = next_id
      self[class_name][:parent] = :Object
      self[class_name][:functions] = { }
      self[class_name][:functions_def] = { }
      self[class_name][:ivars] = {  }
      self[class_name][:cvars] = {  }
      self[class_name][:defined_in_stdlib] = false
    end
    self[class_name][:value] = s().with_value(
                             s(:cast, :'Object*',
                               s(:var, ('&vs'+class_name.to_s).to_sym)),
                             :Class).with_class_type(class_name)
    self[class_name][:type] = :class
  end

  # Setter for cclass -- curent class context
  def cclass=(value)
    @cclass = value
    add_class @cclass unless self.has_key? @cclass
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
    prev_block = @cblock
    @cblock = self[@cclass][:functions][@cfunction]
    retval = yield
    @cfunction = prev_function
    @cblock = prev_block
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
  def in_block
    raise 'Block expected' unless block_given?
    prev_block = @cblock
    @cblock = { lvars: {}, parent: prev_block }
    retval = yield
    @cblock[:lvars].each_key do |k|
      prev_block[:lvars][k] ||= { kind: :local }
      prev_block[:lvars][k][:type] = nil
    end
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
    @cblock[:lvars][lvar] ||= { kind: :local }
  end

  # Checks whether we've got a given local variable in the current function
  # context.
  def has_lvar?(lvar)
    get_lvar(lvar) != nil
  end

  # Sets the given type for the given local variable in the current function
  # context.
  def set_lvar_type(lvar, type)
    @cblock[:lvars][lvar] ||= { kind: :local }
    @cblock[:lvars][lvar][:type] = type
  end

  # Marks the given local variable in the current function context as one
  # of given type (:local or :param)
  def set_lvar_kind(lvar, kind)
    @cblock[:lvars][lvar][:kind] = kind
  end

  # Returns the type for the given local variable in the current function
  # context.
  def get_lvar_type(lvar)
    get_lvar(lvar)[:type]
  end

  # Adds an instance variable in the current class context.
  def add_ivar(ivar)
    ivars_table[ivar] ||= {}
  end

  # Checks whether we've got a given instance variable in the current class
  # context.
  def has_ivar?(ivar)
    get_ivar_class(ivar) != nil
  end

  # Sets the given type for the given instance variable in the current class
  # context.
  def set_ivar_type(ivar, type)
    self[get_ivar_class(ivar)][:ivars][ivar][:type] = type
  end

  # Returns the type for the given instance variable in the current class
  # context.
  def get_ivar_type(ivar)
    self[get_ivar_class(ivar)][:ivars][ivar][:type]
  end

  # Adds an class variable in the current class context.
  def add_cvar(cvar)
    cvars_table[cvar] ||= {}
  end

  # Checks whether we've got a given class variable in the current class
  # context.
  def has_cvar?(cvar)
    get_cvar_class(cvar) != nil
  end

  # Sets the given type for the given class variable in the current class
  # context.
  def set_cvar_type(cvar, type)
    self[get_cvar_class(cvar)][:cvars][cvar][:type] = type
  end

  # Returns the type for the given class variable in the current class
  # context.
  def get_cvar_type(cvar)
    self[get_cvar_class(cvar)][:cvars][cvar][:type]
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

  # The hash of class variables in the current class context.
  def cvars_table
    self[@cclass][:cvars]
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

  # Returns class name if class within class variable is defined
  # or nil if it was not defined.
  def get_cvar_class(cvar)
    cl = @cclass
    begin
      return cl if self[cl][:cvars].has_key? cvar
    end while cl = self[cl][:parent]
    nil
  end

  # Returns class name if class within instance variable is defined
  # or nil if it was not defined.
  def get_ivar_class(ivar)
    cl = @cclass
    begin
      return cl if self[cl][:ivars].has_key? ivar
    end while cl = self[cl][:parent]
    nil
  end

  private
  
  # Returns hash corresponding to local variable or nil if variable does not
  # exist.
  def get_lvar(lvar)
    block = @cblock
    begin
      return block[:lvars][lvar] if block[:lvars].has_key? lvar
    end while block = block[:parent]
    nil
  end

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
