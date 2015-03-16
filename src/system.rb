require_relative 'checker'
require_relative 'other'

class TypeDispatcher
  attr_accessor :validators, :system

  def initialize(system)
    is_method = Proc.new { |klass, sym| klass.instance_methods(false).include? sym }
    is_attribute = Proc.new { |klass, sym| klass.instance_methods(false).include? (sym.to_s+'=').to_sym }
    is_class_method = Proc.new { |klass, sym| klass.singleton_methods(false).include? sym }

    self.system = system
    self.validators = {is_attribute => :accesor_typesig,
                       is_method => :method_typesig,
                       is_class_method => :class_method_typesig
    }
  end

  def dispatch(klass, sym, type_args)
    validators.each do |validator, dispatch_sym|
      if validator.call(klass, sym)
        return system.send dispatch_sym, sym, type_args
      end

    end
  end

end

module TypeSystem

  def get_untyped_method(sym)
    (sym.to_s+'_untyped').to_sym
  end

  def get_untyped_accessor(sym)
    (sym.to_s+'=').to_sym
  end

  def typesig(sym, type_args)
    klass = get_class_from_call_stack caller
    dispatcher = TypeDispatcher.new self
    dispatcher.dispatch klass, sym, type_args
  end

  def accesor_typesig(sym, type_arg)
    real_sym = get_untyped_accessor(sym)
    m = self.instance_method real_sym
    method_sym =get_untyped_accessor(get_untyped_method sym)
    self.send :alias_method, method_sym, real_sym
    TypeDefinition.new(self, m, real_sym, [type_arg]).any
  end

  def class_method_typesig(sym, type_args)
    m = self.singleton_method sym
    method_sym = get_untyped_method sym
    self.singleton_class.send :alias_method, method_sym, sym
    TypeDefinition.new(self, m, sym, type_args).class_compile
  end

  def method_typesig(sym, type_args)
    m = self.instance_method sym
    method_sym = get_untyped_method sym
    self.send :alias_method, method_sym, sym
    TypeDefinition.new(self, m, sym, type_args)
  end

  def get_old_method(method_sym)
    if method_sym.to_s.end_with? '='
      return get_untyped_accessor(get_untyped_method (method_sym.to_s[0..-2]))
    end
    get_untyped_method method_sym
  end

  def enable_class_type_method(method_sym, type_definition)
    old_method = self.get_old_method method_sym
    checker = TypeChecker.new

    self.singleton_class.send :define_method, (method_sym) do |*args|
      checker.check_arguments type_definition, args
      result = self.send old_method.to_sym, *args
      checker.check_return(type_definition, result)
      result
    end
  end

  def enable_type_method(method_sym, type_definition)
    old_method = self.get_old_method method_sym
    checker = TypeChecker.new

    self.send :define_method, (method_sym) do |*args|
      checker.check_arguments type_definition, args
      result = self.send old_method.to_sym, *args
      checker.check_return(type_definition, result)
      result
    end
  end

end