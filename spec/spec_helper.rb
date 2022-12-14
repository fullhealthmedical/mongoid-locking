require "byebug"
require "mongoid/locking"

# helper classes
require "fixtures/address"
require "fixtures/group"
require "fixtures/phone"
require "fixtures/person"
require "fixtures/post"

Mongoid.configure do |config|
  config.connect_to("test")
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
