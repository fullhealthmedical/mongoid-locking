require "spec_helper"

RSpec.describe "Atomic collection persistence methods" do
  let(:john) { Person.create(name: "John") }
  let(:josh) { Person.create(name: "Josh") }
  let(:mary) { Person.create(name: "Mary") }

  before do
    Person.delete_all

    john
    josh
    mary
  end

  shared_examples "incrementing lock_version for all matching documents" do
    it "increments lock_version for all documents" do
      expect(Person.all.pluck(:lock_version)).to eq [1, 1, 1]
    end
  end

  describe "#add_to_set" do
    before { Person.all.add_to_set(aliases: ["Bond"]) }

    it_behaves_like "incrementing lock_version for all matching documents"
  end

  describe "#bit" do
    before { Person.all.bit(age: { and: 10, or: 12 }) }

    it_behaves_like "incrementing lock_version for all matching documents"
  end

  describe "#inc" do
    before { Person.all.inc(age: 2) }

    it_behaves_like "incrementing lock_version for all matching documents"
  end

  describe "#pop" do
    before { Person.all.pop(aliases: 1) }

    it_behaves_like "incrementing lock_version for all matching documents"
  end

  describe "#pull" do
    before { Person.all.pull(aliases: "007") }

    it_behaves_like "incrementing lock_version for all matching documents"
  end

  describe "#pull_all" do
    before { Person.all.pull_all(aliases: %w[007 whatever]) }

    it_behaves_like "incrementing lock_version for all matching documents"
  end

  describe "#push" do
    before { Person.all.push(aliases: %w[Bond]) }

    it_behaves_like "incrementing lock_version for all matching documents"
  end

  describe "#rename" do
    before { Person.all.rename(age: :old_age_field) }

    it_behaves_like "incrementing lock_version for all matching documents"
  end

  describe "#set" do
    before { Person.all.set(name: "Marie") }

    it_behaves_like "incrementing lock_version for all matching documents"
  end
end
