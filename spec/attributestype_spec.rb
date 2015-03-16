require 'rspec'
require_relative '../src/system'
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

      attr_accessor :a_property
      typesig(:a_property, String)

    end

  end

  it 'spec valid attr initialization ' do
    person = Person.new
    person.a_property= "45"
    expect(person.a_property).to eq "45"

  end

  it 'spec error on attr_initialization' do
    person = Person.new
    expect{person.a_property=45}.to raise_error TypeCheckError
  end

end