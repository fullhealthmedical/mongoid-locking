require "spec_helper"

RSpec.describe Mongoid::Locking::Retry do
  let(:existing) { Person.create!(name: "John", age: 50) }

  before do
    Person.delete_all
  end

  it "retries the block when a StaleObjectError is raised" do
    force_stale_error = true

    Person.with_locking do
      person = Person.find(existing.id)

      if force_stale_error
        Person.find(person.id).update(name: "Person 1 updated")
        force_stale_error = false
      end

      person.set(name: "Person 1 updated final")
    end

    expect(existing.reload.name).to eq("Person 1 updated final")
  end

  it "raises the StaleObjectError when the max retries is reached" do
    tries = 0

    expect do
      Person.with_locking do
        tries += 1
        person = Person.find(existing.id)
        Person.find(person.id).set(age: person.age + 1)

        person.set(name: "Person 1 updated final")
      end
    end.to raise_error(Mongoid::StaleObjectError)

    expect(tries).to eq(4)
  end

  context "when called on an instance" do
    it "retries the block when a StaleObjectError is raised" do
      force_stale_error = true

      existing.with_locking do
        if force_stale_error
          Person.find(existing.id).update(name: "Person 1 updated")
          force_stale_error = false
        end

        existing.set(name: "Person 1 updated final")
      end

      expect(existing.reload.name).to eq("Person 1 updated final")
    end

    it "raises the StaleObjectError when the max retries is reached" do
      tries = 0
      expect do
        existing.with_locking do
          tries += 1
          Person.find(existing.id).set(age: existing.age + 1)

          existing.set(name: "Person 1 updated final")
        end
      end.to raise_error(Mongoid::StaleObjectError)

      expect(tries).to eq(4)
    end
  end
end
