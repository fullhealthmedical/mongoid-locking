class Group
  include Mongoid::Document
  include Mongoid::Locking

  field :name, type: String

  has_and_belongs_to_many :people, class_name: "Person", inverse_of: :groups
end
