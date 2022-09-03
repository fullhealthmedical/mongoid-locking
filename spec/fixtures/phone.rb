class Phone
  include Mongoid::Document

  field :number, type: String
  embedded_in :person
end
