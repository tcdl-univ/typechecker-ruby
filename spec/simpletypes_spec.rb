require 'rspec'
require_relative '../src/checker'
require_relative '../src/other'


describe 'Test simple method types' do
  class Class
    include ModuleRemover
  end

  before(:each) do
    class Class
      include TypeSystem
    end

    #Simple fixture
    class Person

      def personal(id)
        34
      end

      typesig(:personal, [Numeric]).to Numeric

      def personal_two_params(id, other_id)
        34
      end

      typesig(:personal_two_params, [Numeric, Numeric]).to Numeric

      def manager
        Person.new
      end

      typesig(:manager, ()).to Person

    end

  end

  it 'spec simple method entry ' do
    person = Person.new
    expect(person.personal 45).to eq 34

  end

  it 'spec simple method entry ' do
    person = Person.new
    expect(person.personal_two_params 2, 45).to eq 34

  end

  it 'spec manager method, no arguments' do
    person = Person.new
    expect((person.manager).class).to eq Person
  end

  it 'spec invalid type' do
    person = Person.new
    expect { person.personal 'ee' }.to raise_error TypeCheckError
  end


  it 'spec arity error' do
    person = Person.new
    expect { person.personal 2, 4 }.to raise_error ArityTypeError
  end


  it 'class with invalid return type' do
    class Bar
      def a_method(i)
        'Hello'
      end

      typesig(:a_method, [Numeric]).to Numeric
    end

    b = Bar.new
    expect { b.a_method 3 }.to raise_error TypeCheckError

  end


end