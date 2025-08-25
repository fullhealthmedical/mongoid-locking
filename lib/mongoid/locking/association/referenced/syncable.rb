# frozen_string_literal: true

module Mongoid
  module Association
    module Referenced
      # This module handles the behavior for synchronizing foreign keys between
      # both sides of a many to many associations.
      module Syncable
        # Update the inverse keys for the association.
        #
        # @example Update the inverse keys
        #   document.update_inverse_keys(association)
        #
        # @param [ Association ] association The document association.
        #
        # @return [ Object ] The updated values.
        def update_inverse_keys(association)
          return unless previous_changes.has_key?(association.foreign_key)

          old, new = previous_changes[association.foreign_key]
          adds = new - (old || [])
          subs = (old || []) - new

          # If we are autosaving we don't want a duplicate to get added - the
          # $addToSet would run previously and then the $push and $each from the
          # inverse on the autosave would cause this. We delete each id from
          # what's in memory in case a mix of id addition and object addition
          # had occurred.
          if association.autosave?
            send(association.name).in_memory.each do |doc|
              adds.delete_one(doc._id)
            end
          end

          if _association_in_memory_locking?(association)
            _increase_lock_version_in_memory(send(association.name).in_memory)
          end

          unless adds.empty?
            association.criteria(self, adds).without_options.add_to_set(association.inverse_foreign_key => _id)
          end
          return if subs.empty?

          association.criteria(self, subs).without_options.pull(association.inverse_foreign_key => _id)
        end

        private

        def _increase_lock_version_in_memory(docs)
          docs.each do |doc|
            doc.lock_version = (doc.lock_version || 0) + 1
            doc.remove_change("lock_version")
          end
        end

        def _association_in_memory_locking?(association)
          association.klass.included_modules.include?(::Mongoid::Locking)
        end
      end
    end
  end
end
