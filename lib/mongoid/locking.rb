require "mongoid"
require_relative "locking/version"
require_relative "stale_object_error"
require_relative "locking/contextual/atomic"
require_relative "locking/contextual/mongo"
require_relative "locking/helpers"
require_relative "locking/persistable"
require_relative "locking/persistable/updatable"

module Mongoid
  ##
  # Adds optimistic locking to a Mongoid::Document class.
  #
  # @since 0.1.0
  module Locking
    def self.included(base)
      base.field :lock_version, type: Integer
      base.before_create { self.lock_version = 0 }

      base.include Mongoid::Locking::Helpers
      base.include Mongoid::Locking::Persistable
      base.include Mongoid::Locking::Persistable::Updatable
    end
  end
end

Mongoid::Contextual::Mongo.prepend Mongoid::Locking::Contextual::Mongo
Mongoid::Contextual::Mongo.prepend Mongoid::Locking::Contextual::Atomic
