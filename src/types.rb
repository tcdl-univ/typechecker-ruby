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
  attr_accessor :method, :method_sym, :entry_args, :return_type, :klass, :annon_index

  def initialize(klass, method, method_sym, type_args)
    self.annon_index = 1
    self.entry_args = []
    self.method=method
    self.klass = klass
    self.method_sym = method_sym
    entry_arguments = self.get_entry_args_types type_args
    entry_arguments.each do |argument_types|
      self.entry_args << (SimpleType.new *argument_types)
    end
  end

  def get_method_names
    self.method.parameters.map { |a| a[1] }
  end

  def set_anon_attributes_name(member)
    if member.length < 3
     member =  [member[0], "anon_attr_#{self.annon_index}", member[1]]
     self.annon_index += 1
    end
    member
  end

  def get_entry_args_types(entry_args)
    unless self.method.parameters.empty?
      arguments = self.method.parameters.zip entry_args
      arguments = arguments.map { |each| each.flatten }
      return arguments.map { |each| set_anon_attributes_name(each) }
    end
    []
  end

  def to(return_type)
    self.return_type =return_type
    #encadenate the
    self.klass.enable_type_method self.method_sym, self
  end

  def class_compile(return_type= Object)
    self.return_type =return_type
    #encadenate the
    self.klass.enable_class_type_method self.method_sym, self
  end

  def any()
    self.to(Object)
  end
end
