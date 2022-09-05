require "spec_helper"

RSpec.describe "Standard peristence methods" do
  let(:person) { Person.create(name: "John") }

  context "when creating" do
    it "initializes lock_version in Mongoid::Document instance to 0" do
      expect(person.lock_version).to eq 0
    end

    it "saves document with lock_version 0" do
      expect(person.reload.lock_version).to eq 0
    end

    it "does not add lock_version to changes" do
      expect(person.changes).to be_empty
    end
  end

  context "when updating" do
    let(:person) { Person.create(name: "John") }

    context "when performing basic updates" do
      before { person.update(name: "Marie") }

      it "increments lock_version in Mongoid::Document instance" do
        expect(person.lock_version).to eq 1
      end

      it "increments lock_version on database" do
        expect(person.reload.lock_version).to eq 1
      end

      it "updated document" do
        expect(person.reload.name).to eq "Marie"
      end
    end

    context "when the object does not have lock_version yet" do
      let(:person) do
        Person.collection.drop
        # insert a document without lock_version field (needs to be done outside mongoid)
        Person.collection.insert_one({ name: "John" })
        Person.find_by!(name: "John")
      end

      before do
        person.reload.update(name: "Marie")
      end

      it "increments lock_version in Mongoid::Document instance" do
        expect(person.lock_version).to eq 1
      end

      it "increments lock_version on database" do
        expect(person.reload.lock_version).to eq 1
      end

      it "updates document" do
        expect(person.reload.name).to eq "Marie"
      end
    end

    context "when saving multple times using same instances" do
      before do
        person.update(name: "Mary")
        person.update(name: "Victor")
        person.update(name: "Roger")
      end

      it "increments lock_version in Mongoid::Document instance" do
        expect(person.lock_version).to eq 3
      end

      it "increments lock_version on database" do
        expect(person.reload.lock_version).to eq 3
      end

      it "updates document" do
        expect(person.name).to eq "Roger"
      end
    end

    context "when saving multple times using different instances" do
      before do
        Person.find(person.id).update(name: "Mary")
        Person.find(person.id).update(name: "Victor")
        Person.find(person.id).update(name: "Roger")
        person.reload
      end

      it "increments lock_version in Mongoid::Document instance" do
        expect(person.lock_version).to eq 3
      end

      it "increments lock_version on database" do
        expect(person.reload.lock_version).to eq 3
      end

      it "updates document" do
        expect(person.name).to eq "Roger"
      end
    end

    context "when updating using an stale object" do
      it "raises a StaleObjectError" do
        p1 = Person.find(person.id)
        p2 = Person.find(person.id)

        p1.update(name: "Paul")
        expect { p2.update(name: "Jack") }.to raise_error Mongoid::StaleObjectError
      end
    end

    context "when updating without changes" do
      before do
        person.update(name: "Marie")
        person.update(name: "Marie")
      end

      it "doesn't increment lock_version in Mongoid::Document instance" do
        expect(person.lock_version).to eq 1
      end

      it "doesn't increment lock_version on database" do
        expect(person.reload.lock_version).to eq 1
      end
    end
  end

  context "when creating embedded document" do
    before do
      person.create_address street: "Main Street"
    end

    it "increments lock_version in Mongoid::Document instance" do
      expect(person.lock_version).to eq 1
    end

    it "increments lock_version on database" do
      expect(person.reload.lock_version).to eq 1
    end

    it "updated document" do
      expect(person.reload.address).to be_present
    end
  end

  context "when creating embedded document directly" do
    let(:person) { Person.new(name: "John") }

    before do
      address = Address.new(street: "Main Street", person: person)
      address.save
    end

    it "sets lock_version in Mongoid::Document instance" do
      expect(person.lock_version).to eq 0
    end

    it "sets lock_version on database" do
      expect(person.reload.lock_version).to eq 0
    end

    it "updated document" do
      expect(person.reload.address).to be_present
    end
  end

  context "when updating embedded document" do
    let(:address) { person.create_address street: "Main Street 1" } # version 1

    before do
      address.update(street: "Main Street 2") # version 1
    end

    it "increments lock_version in Mongoid::Document instance" do
      expect(person.lock_version).to eq 2
    end

    it "increments lock_version on database" do
      expect(person.reload.lock_version).to eq 2
    end

    it "updated document" do
      expect(person.reload.address.street).to eq "Main Street 2"
    end
  end

  context "when creating with associations" do
    before do
      Person.delete_all
      Group.delete_all
    end

    it "increments lock_version in both Mongoid::Document instance" do
      person = Person.create(name: "John")
      group = Group.create(name: "Group 1")

      group.people << person
      group.save

      expect(group.lock_version).to eq 1
      expect(person.reload.groups).to eq [group]
      expect(person.lock_version).to eq 1
    end
  end
end
