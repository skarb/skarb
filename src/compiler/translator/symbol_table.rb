require 'helpers'
require 'translator/event_manager'
require 'translator/mangling'

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
  include Mangling

  ChangeValueEvent = Struct.new(:old_value, :new_value)
  FunctionEvent = Struct.new(:function)

  attr_reader :cclass, :cfunction, :cblock

  def initialize
    @event_manager = EventManager.new

    self.cclass = :Object
    class_table[:parent] = nil
    self.cclass = Translator::MainObject
    self.cfunction = :_main
    @cblock = self[@cclass][:functions][@cfunction]
    @fname2id = {}
  end

  def subscribe(event, method)
    @event_manager.subscribe(event, method)
  end

  # Adds a new constant and generates id for it.
  def add_constant(name, value)
    self[name] ||= { }
    self[name].merge!({:value => value, :type => :const})
  end 

  # Adds a new class, generates id for it and initializes mandatory
  # keys with default values.
  def add_class(class_name)
    self[class_name] ||= { }
    if self[class_name][:type] == :const
      die "#{class_name} is not a class"
    end
    if self[class_name][:id].nil?
      self[class_name] = {
        :id => next_id,
        :parent => :Object,
        :functions => {},
        :functions_def => {},
        :ivars => {},
        :cvars => {},
        :defined_in_stdlib => false
      }
    end
    cvars_struct_var = mangle_cvars_struct_var_name class_name
    self[class_name][:value] = s().with_value(
                             s(:cast, :'Object*',
                               s(:var, ('&'+cvars_struct_var.to_s).to_sym)),
                             :Class).with_class_type(class_name)
    self[class_name][:type] = :class
  end

  # Setter for cclass -- curent class context
  def cclass=(value)
    prev_value = @cclass
    @cclass = value
    add_class @cclass unless self.has_key? @cclass
    @event_manager.fire_event(:cclass_changed,
                              ChangeValueEvent.new(prev_value, value))
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
    prev_value = @cfunction
    @cfunction = value
    self[@cclass][:functions][@cfunction] ||= {}
    self[@cclass][:functions][@cfunction][:lvars] ||= {}
    @event_manager.fire_event(:cfunction_changed,
                              ChangeValueEvent.new(prev_value, value))
  end

  # Executes a block in a given function context and resets the current function
  # to the previous value.
  def in_function(name, fun_def)
    raise 'Block expected' unless block_given?

    # Enter new function context and open its basic block.
    prev_function = @cfunction
    self.cfunction = name
    self[@cclass][:functions][@cfunction][:def] = fun_def
    prev_block = @cblock
    @cblock = self[@cclass][:functions][@cfunction]
    @event_manager.fire_event(:function_opened, FunctionEvent.new(name))
    
    # Execute code.
    retval = yield
    
    # Change the context to the previous function and block.
    @cfunction = prev_function
    @cblock = prev_block
    @event_manager.fire_event(:function_closed, FunctionEvent.new(name))
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
    
    # Open new block
    prev_block = @cblock
    @cblock = { lvars: {}, parent: prev_block }
    @event_manager.fire_event(:block_opened, nil)

    # Execute code in block
    retval = yield

    # Update variables in upper blocks
    @cblock[:lvars].each do |k,v|
      block = prev_block
      begin
        var_hash = block[:lvars][k] if block[:lvars].has_key? k
      end while block = block[:parent]
      if var_hash.nil?
        # If variable was not defined in any super block
        prev_block[:lvars][k] = { kind: :local }
        var_hash = prev_block[:lvars][k]
      end
      var_hash[:type] = nil unless var_hash[:type] == v[:type]
    end

    # Close block
    @cblock = prev_block
    @event_manager.fire_event(:block_closed, nil)
    
    retval
  end

  # Adds function in the current class context
  def add_function(fun, sexp)
    @fname2id[fun] ||= fnext_id
    self[@cclass][:functions_def][fun] ||= []
    self[@cclass][:functions_def][fun].push sexp
  end

  # Returns unique id for given function name
  def get_function_id(fun_name)
    @fname2id[fun_name] ||= fnext_id
  end

  # Returns function version in a given class context
  def function_version(cls, fun)
    self[cls][:functions_def][fun].length - 1
  end

  # Returns the most recent function definition in a given class context
  def function_def(cls, fun)
    self[cls][:functions_def][fun].last
  end

  # Check if function with given name is defined for a given class
  def has_function?(cls, name)
    self[cls][:functions_def].has_key? name
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

  # Returns hash corresponding to instance variable or nil if variable does not
  # exist.
  def get_ivar(ivar)
    cl = get_ivar_class(ivar)
    return nil if cl.nil?
    ivar_table(cl)[ivar]
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

  # Returns hash corresponding to class variable or nil if variable does not
  # exist.
  def get_cvar(cvar)
    cl = get_cvar_class(cvar)
    return nil if cl.nil?
    cvar_table(cl)[cvar]
  end

  # The hash of instance variables in a given (or current by default) class
  # context.
  def ivars_table(cls=@cclass)
    self[cls][:ivars]
  end

  # The hash of class variables in a given (or current by default) class
  # context.
  def cvars_table(cls=@cclass)
    self[cls][:cvars]
  end

  # General hash of current class context.
  def class_table
    self[@cclass]
  end

  # General hash of current function context.
  def function_table
    self[@cclass][:functions][@cfunction]
  end

  # The hash of local variables in the current function context.
  def lvars_table
    self[@cclass][:functions][@cfunction][:lvars]
  end

  # True if instanced of this class can be allocated atomicly (object structure
  # contains no pointers). If no class name is given the current class is taken
  # as a default.
  def class_atomic_alloc?(class_name=@cclass)
    self[class_name][:atomic_alloc]
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

  # Type returned by the current function
  def returned_type
    type = function_table[:rettype]
    type == :any ? nil : type
  end

  # Sets the returned_type. If it has been already set to a different value it's
  # set to :any, which means that the returned type cannot be determined.
  def returned_type=(type)
    current = function_table[:rettype]
    if type.nil?
      function_table[:rettype] = :any
    elsif current.nil?
      function_table[:rettype] = type
    elsif current != type
      function_table[:rettype] = :any
    end
  end

  # Sets the returned_type to nil. Using returned_type= won't work as it would
  # set it to :any.
  def forget_returned_type
    function_table[:rettype] = nil
  end

  # Returns the id of a class.
  def id_of(cls)
    self[cls][:id]
  end

  # Returns the id of a class.
  def value_of(cls)
    self[cls][:value]
  end
  
  # Returns hash corresponding to local variable or nil if variable does not
  # exist.
  def get_lvar(lvar)
    block = @cblock
    begin
      return block[:lvars][lvar] if block[:lvars].has_key? lvar
    end while block = block[:parent]
    nil
  end
  
  private
  
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

  protected

  # Indexing from outside is forbidden.
  def [](x)
    super x
  end

  # Indexing from outside is forbidden.
  def []=(x, y)
    super x, y
  end
end
