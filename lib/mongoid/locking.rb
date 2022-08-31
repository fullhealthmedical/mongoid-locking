# frozen_string_literal: true

require_relative "locking/version"

module Mongoid
  ##
  # Adds optimistic locking to a Mongoid::Document class.
  #
  # @since 0.1.0
  module Locking
    def self.included(base)
      base.field :lock_version, type: Integer
      base.before_create { self.lock_version = 0 }
    end
  end
end
