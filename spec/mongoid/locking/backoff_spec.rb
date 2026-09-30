require "spec_helper"

RSpec.describe "Mongoid::Locking.backoff_algorithm" do
  after do
    Mongoid::Locking.backoff_base = nil
    Mongoid::Locking.backoff_cap = nil
  end

  it "waits up to base * 2**retries seconds" do
    allow(Mongoid::Locking).to receive(:rand).and_return(1.0)

    expect([1, 2, 3].map { |r| Mongoid::Locking.backoff_algorithm(r) }).to eq([0.2, 0.4, 0.8])
  end

  it "picks a random delay from zero to the ceiling" do
    allow(Mongoid::Locking).to receive(:rand).and_return(0.25)

    expect(Mongoid::Locking.backoff_algorithm(2)).to eq(0.1)
  end

  it "caps the delay" do
    allow(Mongoid::Locking).to receive(:rand).and_return(1.0)

    expect(Mongoid::Locking.backoff_algorithm(10)).to eq(1.0)
  end

  it "uses the configured base and cap" do
    allow(Mongoid::Locking).to receive(:rand).and_return(1.0)
    Mongoid::Locking.backoff_base = 0.02
    Mongoid::Locking.backoff_cap = 0.05

    expect([1, 2].map { |r| Mongoid::Locking.backoff_algorithm(r) }).to eq([0.04, 0.05])
  end
end
