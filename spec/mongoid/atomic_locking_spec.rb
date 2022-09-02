require "spec_helper"

RSpec.describe "Atomic persistence methods" do
  let(:person) { Person.create(name: "James", age: 50, aliases: ["007"]) }

  describe "#add_to_set" do
    before { person.add_to_set(aliases: ["Bond"]) }

    it "increments lock_version in Mongoid::Document instance" do
      expect(person.lock_version).to eq 1
    end

    it "increments lock_version on database" do
      expect(person.reload.lock_version).to eq 1
    end

    it "updates document" do
      expect(person.reload.aliases).to include("Bond")
    end
  end

  describe "#bit" do
    before { person.bit(age: { and: 10, or: 12 }) }

    it "increments lock_version in Mongoid::Document instance" do
      expect(person.lock_version).to eq 1
    end

    it "increments lock_version on database" do
      expect(person.reload.lock_version).to eq 1
    end

    it "updates document" do
      expect(person.reload.age).to eq 14
    end
  end

  describe "#inc" do
    before { person.inc(age: 2) }

    it "increments lock_version in Mongoid::Document instance" do
      expect(person.lock_version).to eq 1
    end

    it "increments lock_version on database" do
      expect(person.reload.lock_version).to eq 1
    end

    it "updates document" do
      expect(person.reload.age).to eq 52
    end
  end

  describe "#pop" do
    before { person.pop(aliases: 1) }

    it "increments lock_version in Mongoid::Document instance" do
      expect(person.lock_version).to eq 1
    end

    it "increments lock_version on database" do
      expect(person.reload.lock_version).to eq 1
    end

    it "updates document" do
      expect(person.reload.aliases).to eq []
    end
  end

  describe "#pull" do
    before { person.pull(aliases: "007") }

    it "increments lock_version in Mongoid::Document instance" do
      expect(person.lock_version).to eq 1
    end

    it "increments lock_version on database" do
      expect(person.reload.lock_version).to eq 1
    end

    it "updates document" do
      expect(person.reload.aliases).to eq []
    end
  end

  describe "#pull_all" do
    before { person.pull_all(aliases: %w[007 whatever]) }

    it "increments lock_version in Mongoid::Document instance" do
      expect(person.lock_version).to eq 1
    end

    it "increments lock_version on database" do
      expect(person.reload.lock_version).to eq 1
    end

    it "updates document" do
      expect(person.reload.aliases).to eq []
    end
  end

  describe "#push" do
    before { person.push(aliases: %w[Bond]) }

    it "increments lock_version in Mongoid::Document instance" do
      expect(person.lock_version).to eq 1
    end

    it "increments lock_version on database" do
      expect(person.reload.lock_version).to eq 1
    end

    it "updates document" do
      expect(person.reload.aliases).to include("Bond")
    end
  end

  describe "#rename" do
    before { person.rename(age: :old_age_field) }

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

  describe "#set" do
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
