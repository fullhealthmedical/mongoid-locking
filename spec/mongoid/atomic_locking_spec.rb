require "spec_helper"

RSpec.describe "Atomic persistence methods" do
  describe "#set" do
    let(:person) { Person.create(name: "John") }

    before { person.set(name: "Marie") }

    it "increments lock_version in Mongoid::Document instance" do
      expect(person.lock_version).to eq 1
    end

    it "increments lock_version on database" do
      expect(person.reload.lock_version).to eq 1
    end

    it "updates document" do
      expect(person.name).to eq "Marie"
    end

    context "when saving multple times using same instance" do
      before do
        person.set(name: "Victor")
        person.set(name: "Roger")
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
        Person.find(person.id).set(name: "Victor")
        Person.find(person.id).set(name: "Roger")
        person.reload
      end

      it "increments lock_version" do
        expect(person.lock_version).to eq 3
      end

      it "updates document" do
        expect(person.name).to eq "Roger"
      end
    end

    context "when updating the record by duplicated instances" do
      it "raises a StaleObjectError" do
        p1 = Person.find(person.id)
        p2 = Person.find(person.id)

        p1.set(name: "Paul")
        expect { p2.set(name: "Jack") }.to raise_error Mongoid::StaleObjectError
      end
    end

    context "when updating without changes" do
      # In this scenario we are making no changes to the document, but we still
      # increment the lock_version as a mongo $set operation is performed.
      before do
        person.set(name: "Marie")
      end

      it "increments lock_version in Mongoid::Document instance" do
        expect(person.lock_version).to eq 2
      end

      it "increments lock_version on database" do
        expect(person.reload.lock_version).to eq 2
      end
    end
  end

  describe "#unset" do
    let(:person) { Person.create(name: "John", age: 50) }

    before { person.unset(:age) }

    it "increments lock_version in Mongoid::Document instance" do
      expect(person.lock_version).to eq 1
    end

    it "increments lock_version on database" do
      expect(person.reload.lock_version).to eq 1
    end

    it "updates document" do
      expect(person.reload.age).to be_nil
    end
  end
end
