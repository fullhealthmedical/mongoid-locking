class Phone
  include Mongoid::Document

  field :number, type: String
  embedded_in :person

  has_and_belongs_to_many :tags, inverse_of: nil
end
