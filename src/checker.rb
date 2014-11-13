class GenericType
  attr_accessor :type, :generic_type

  def initialize(type, generic_type)
    self.type=type
    self.generic_type=generic_type
  end
end

class TypeDefinition
  attr_accessor :method, :method_sym, :entry_args, :return_type, :klass

  def get_method_names
    self.method.parameters.map { |a| a[1] }
  end


  def initialize(klass, method, method_sym, type_args)
    self.method=method
    self.klass = klass
    self.method_sym = method_sym
    self.entry_args =type_args
  end

  def to(return_type)
    self.return_type =return_type
    #encadenate the
    self.klass.enable_type_method self.method_sym, self.method.parameters, self
  end
end

class TypeChecker

  def check_return(type_definition,result)

  end

  def check_arguments(type_definition, entry_arguments)

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

  def enable_type_method(method_sym, method_args, type_definition)
    old_method = get_untyped_method(method_sym)
    checker = TypeChecker.new
    self.send :define_method,(method_sym) do method_args
    checker.check_arguments type_definition, method_args
    result = self.send old_method.to_sym *method_args
    checker.check_return(type_definition, result)
    result
    end
  end

end

