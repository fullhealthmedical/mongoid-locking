class Person
  include Mongoid::Document
  include Mongoid::Locking

  field :name, type: String
  field :age, type: Integer
end
