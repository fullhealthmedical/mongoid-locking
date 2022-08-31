require "spec_helper"

RSpec.describe Mongoid::Locking do
  let(:locked_document) do
    Class.new do
      include Mongoid::Document
      include Mongoid::Locking
      store_in collection: "test"

      field :name, type: String
      field :age, type: Integer
    end
  end

  it "has a version number" do
    expect(Mongoid::Locking::VERSION).not_to be nil
  end

  it "adds lock_version field to the document" do
    expect(locked_document.fields.keys).to include("lock_version")
  end

  context "when creating" do
    let(:person) { locked_document.create(name: "John") }

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
    let(:person) { locked_document.create(name: "John") }

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
        locked_document.collection.drop
        # insert a document without lock_version field (needs to be done outside mongoid)
        locked_document.collection.insert_one({ name: "John" })
        locked_document.find_by!(name: "John")
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
        locked_document.find(person.id).update(name: "Mary")
        locked_document.find(person.id).update(name: "Victor")
        locked_document.find(person.id).update(name: "Roger")
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
        p1 = locked_document.find(person.id)
        p2 = locked_document.find(person.id)

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

  context "with #set" do
    let(:person) { locked_document.create(name: "John") }

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
        locked_document.find(person.id).set(name: "Victor")
        locked_document.find(person.id).set(name: "Roger")
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
        p1 = locked_document.find(person.id)
        p2 = locked_document.find(person.id)

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

  context "with #unset" do
    let(:person) { locked_document.create(name: "John", age: 50) }

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
