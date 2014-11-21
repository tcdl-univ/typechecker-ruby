class GenericType
  attr_accessor :type, :generic_type

  def initialize(type, generic_type)
    self.type=type
    self.generic_type=generic_type
  end
end

class SimpleType

  attr_accessor :type, :name, :type_argument

  def initialize(type_argument, name, type)
    self.type = type
    self.name = name
    self.type_argument = type_argument
  end

  def is_valid_type?(object)
    unless object.is_a? self.type
      raise TypeCheckError
    end
  end

end

class TypeDefinition
  attr_accessor :method, :method_sym, :entry_args, :return_type, :klass

  def get_method_names
    self.method.parameters.map { |a| a[1] }
  end

  def get_entry_args_types(entry_args)
    unless self.method.parameters.empty?
      arguments = self.method.parameters.zip entry_args
      return arguments.map { |each| each.flatten }
    end
    []
  end

  def initialize(klass, method, method_sym, type_args)
    self.entry_args = []
    self.method=method
    self.klass = klass
    self.method_sym = method_sym
    entry_arguments = self.get_entry_args_types type_args
    entry_arguments.each do |argument_types|
      self.entry_args << (SimpleType.new *argument_types)
    end
  end

  def to(return_type)
    self.return_type =return_type
    #encadenate the
    self.klass.enable_type_method self.method_sym, self
  end
end

class TypeChecker

  def check_return(type_definition, result)
    unless result.is_a? type_definition.return_type
      raise TypeCheckError
    end
  end

  def check_arguments(type_definition, entry_arguments)
    self.check_arity entry_arguments, type_definition.get_method_names
    unless type_definition.entry_args.empty?
      check_arguments= type_definition.entry_args.zip entry_arguments
      check_arguments.each do |type, argument|
        type.is_valid_type? argument
      end
    end
  end

  def check_arity(entry_arguments, expected_arguments)
    #TODO: fix when variable arity arises
    unless entry_arguments.length == expected_arguments.length
      raise ArityTypeError
    end
  end

end

class TypeCheckerValidator

  attr_accessor :param, :type

  def initialize(param, type)
    self.param = param
    self.type = type
  end

  def validate_value_type(value)
    raise "TypeError: #{value} is not type of #{self.type}" unless value.class == self.type
  end

end

module TypeSystem

  def get_untyped_method(sym)
    (sym.to_s+'_untyped').to_sym
  end

  def typesig(sym, type_args)
    m = self.instance_method sym
    method_sym = get_untyped_method sym
    self.send :alias_method, method_sym, sym
    TypeDefinition.new(self, m, sym, type_args)
  end

  def enable_type_method(method_sym, type_definition)
    old_method = get_untyped_method(method_sym)
    checker = TypeChecker.new
    #print method_args
    self.send :define_method, (method_sym) do |*args|
      checker.check_arguments type_definition, args
      result = self.send old_method.to_sym, *args
      checker.check_return(type_definition, result)
      result
    end
  end

end

class TypeCheckError < StandardError
end

class ArityTypeError < TypeCheckError
end

