require "mongoid"
require_relative "locking/version"
require_relative "stale_object_error"
require_relative "locking/contextual/atomic"
require_relative "locking/contextual/mongo"
require_relative "locking/selectable"
require_relative "locking/reloadable"
require_relative "locking/persistable/creatable"
require_relative "locking/persistable/updatable"
require_relative "locking/persistable"

module Mongoid
  ##
  # Adds optimistic locking to a Mongoid::Document class.
  #
  # @since 0.1.0
  module Locking
    def self.included(base)
      base.field :lock_version, type: Integer
      base.before_create { self.lock_version = 0 }

      base.include Mongoid::Locking::Selectable
      base.include Mongoid::Locking::Reloadable
      # base.include Mongoid::Locking::Reloadable if Mongoid::VERSION >= "7"
    end
  end
end

# monkey patching for collection updates
Mongoid::Contextual::Mongo.prepend Mongoid::Locking::Contextual::Mongo
Mongoid::Contextual::Mongo.prepend Mongoid::Locking::Contextual::Atomic

# monkey patching for document updates
Mongoid::Persistable.prepend Mongoid::Locking::Persistable
