require "spec_helper"

RSpec.describe Mongoid::Locking do
  it "has a version number" do
    expect(Mongoid::Locking::VERSION).not_to be nil
  end

  it "adds lock_version field to the document" do
    expect(Person.fields.keys).to include("lock_version")
  end
end
