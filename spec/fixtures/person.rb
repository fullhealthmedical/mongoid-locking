class Person
  include Mongoid::Document
  include Mongoid::Locking

  field :name, type: String
  field :age, type: Integer
  field :aliases, type: Array

  embeds_one :address
  embeds_many :phones

  has_and_belongs_to_many :groups, class_name: "Group", inverse_of: :people
end
