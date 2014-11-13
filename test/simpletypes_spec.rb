require 'rspec'
require_relative '../src/checker'
require_relative '../src/other'



describe  'Test simple method types' do
  class Class
    include ModuleRemover
  end

  before(:each) do
    class Class
      include TypeSystem
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
  end

  after(:each) do
     Class.remove_module TypeSystem
  end

  it 'test simple method entry ' do
     person = Person.new
     expect(person.personal 45).to eq 34
  end


end