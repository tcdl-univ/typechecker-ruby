class Class
  include TypeSystem
end

class A

end

class Person

  def personal(id)
    34
  end

  typesig(:personal, (Numeric)).to Numeric


  def manager
    A.new
  end

  typesig(:manager, ()).to Person

end

#class Manager<Person
#  def employees
#    [Person.new, Person.new]
#  end
#  typesig(:employees, ()).to GenericType.new(Array, Person)
#
#end
#
#m = Manager.new
#print m.employees.class