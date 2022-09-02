require "spec_helper"

RSpec.describe "Standard collection persistence methods" do
  let(:john) { Person.create(name: "John") }
  let(:josh) { Person.create(name: "Josh") }
  let(:mary) { Person.create(name: "Mary") }

  before do
    Person.delete_all

    john
    josh
    mary
  end

  context "when updating a document in a collection" do
    before do
      Person.all.order(name: :asc).update(age: 20)
    end

    it "increments lock_version for matching document" do
      expect(john.reload.lock_version).to eq 1
    end

    it "doesnt increment lock_version for other documents" do
      expect(josh.reload.lock_version).to eq 0
    end
  end

  context "when updating a collection" do
    before do
      Person.all.order(name: :asc).update_all(age: 20)
    end

    it "increments lock_version for all documents" do
      expect(Person.all.pluck(:lock_version)).to eq [1, 1, 1]
    end
  end
end
