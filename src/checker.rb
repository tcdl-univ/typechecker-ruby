require_relative 'types'

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

class TypeCheckError < TypeError
end

class ArityTypeError < TypeCheckError
end

