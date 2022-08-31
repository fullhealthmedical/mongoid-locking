# frozen_string_literal: true

RSpec.describe Mongoid::Locking do
  it "has a version number" do
    expect(Mongoid::Locking::VERSION).not_to be nil
  end
end
