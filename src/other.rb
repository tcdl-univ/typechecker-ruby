module ModuleRemover

  def remove_module(mod, options = {})
    metaclass = class << self; self end
    mod.instance_methods.each {|method_name| metaclass.class_eval { undef_method(method_name.to_sym) }}
  end

end


def get_class_from_call_stack(caller)
  class_name = caller[0]
  class_name = class_name.scan(/([A-Z]\w+)/).first.last
  Kernel.const_get class_name
end