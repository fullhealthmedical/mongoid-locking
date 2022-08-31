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

    def update_document(options = {})
      prepare_update(options) do
        updates, conflicts = init_atomic_updates
        return if updates.empty?

        coll = collection(_root)
        selector = _add_lock_version_to_selector(atomic_selector)

        _update_one_locked(coll, selector, updates)

        conflicts.each_pair do |key, value|
          coll.find(selector).update_one(positionally(selector, { key => value }), session: _session)
        end
      end
    end

    def persist_atomic_operations(operations)
      return unless persisted? && operations.present?

      selector = _add_lock_version_to_selector(atomic_selector)
      _update_one_locked(_root.collection, selector, operations)
    end

    def _update_one_locked(collection, selector, updates)
      updates["$inc"] ||= {}
      updates["$inc"]["lock_version"] = 1

      result = collection.find(selector).update_one(positionally(selector, updates), session: _session)
      raise Mongoid::StaleObjectError, self.class.name.try(:downcase) if result.n < 1

      self.lock_version = (lock_version || 0) + 1
      remove_change(:lock_version)
    end

    def _add_lock_version_to_selector(selector)
      if embedded? || lock_version.nil?
        selector
      else
        selector.merge("lock_version" => lock_version)
      end
    end
  end

  class StaleObjectError < Mongoid::Errors::MongoidError
  end
end
