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

    it "saves with lock_version 0" do
      expect(person.lock_version).to eq 0
      expect(person.reload.lock_version).to eq 0
    end
  end
end
