require "spec_helper"

RSpec.describe Mongoid::Locking::Selectable do
  context "when Document has locking" do
    let(:person) { Person.create(name: "John") }

    it "adds lock_version to the list of fields to select" do
      expect(person.atomic_selector.keys).to include("lock_version", "_id")
    end
  end

  context "when Document does not have locking" do
    let(:post) { Post.create(title: "Hello world") }

    it "does not add lock_version to the list of fields to select" do
      expect(post.atomic_selector.keys).not_to include("lock_version")
    end
  end
end
