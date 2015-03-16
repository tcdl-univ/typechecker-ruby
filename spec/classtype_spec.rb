require 'rspec'
require_relative '../src/system'
require_relative '../src/other'


describe 'Test simple class method types' do
  class Class
    include ModuleRemover
  end

  before(:each) do
    class Class
      include TypeSystem
    end

    #Simple fixture
    class Person

      def self.personal(id)
        34
      end

      typesig(:personal, [Numeric])


      def self.class_manager
        Person.new
      end

      typesig(:class_manager, ())

    end

  end

  it 'spec simple method entry ' do
    person = Person.new
    expect(person.class.personal 45).to eq 34
  end

  it 'spec manager method, no arguments' do
    person = Person.new
    expect((person.class.class_manager).class).to eq Person
  end

  it 'spec invalid type' do
    person = Person.new
    expect { person.class.personal 'ee' }.to raise_error TypeCheckError
  end


  it 'spec arity error' do
    person = Person.new
    expect { person.class.personal 2, 4 }.to raise_error ArityTypeError
  end


end