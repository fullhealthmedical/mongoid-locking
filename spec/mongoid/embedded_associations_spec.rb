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

  context "when updating embedded document association" do
    let(:phone) { Phone.new(number: "1234567890") }

    it "increments lock_version in root instance" do
      expect do
        person.phones << phone
        phone.tags << Tag.new(name: "home")
        phone.tags << Tag.create!(name: "work")
      end.to change(person, :lock_version).from(0).to(3)
    end
  end

  context "when updating association reference" do
    it "increments lock_version for each mirrored association" do
      expect do
        person.groups << Group.create(name: "home")
        person.groups << Group.create(name: "work")
      end.to change(person, :lock_version).from(0).to(2)
    end

    it "increments lock_version for each association reference" do
      expect do
        person.tags << Tag.create(name: "home")
        person.tags << Tag.create(name: "work")
        person.tags = [Tag.create(name: "new")] # triggers 2 updates
      end.to change(person, :lock_version).from(0).to(4)
    end
  end
end
