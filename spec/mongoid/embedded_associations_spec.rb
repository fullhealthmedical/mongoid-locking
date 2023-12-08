require "spec_helper"

RSpec.describe "Embedded associations" do
  let(:person) { Person.create(name: "James", age: 50) }

  context "when adding multiple embedded documents in sequence" do
    it "increments lock_version in root for each added embedded document" do
      expect do
        person.phones << Phone.new(number: "1234567890")
        person.phones << Phone.new(number: "0987654321")
        person.phones << Phone.new(number: "0987654321")
      end.to change(person, :lock_version).from(0).to(3)
    end

    it "increments lock_version in root for each saved embedded document" do
      expect do
        Phone.create!(number: "1234567890", person: person)
        Phone.create!(number: "0987654321", person: person)
        Phone.create!(number: "0987654321", person: person)
      end.to change(person, :lock_version).from(0).to(3)
    end
  end

  context "when updating embedded documents" do
    let(:phone1) { Phone.new(number: "1234567890") }
    let(:phone2) { Phone.new(number: "0987654321") }
    let(:phone3) { Phone.new(number: "0987654323") }

    it "updates embedded association multiple times" do
      person.phones = [phone1, phone2]
      expect(Person.find(person.id).phones).to eq([phone1, phone2])

      person.update!(age: 52) # some other update to increment lock_version

      person.phones = [phone3]
      expect(Person.find(person.id).phones).to eq([phone3])
    end
  end
end
