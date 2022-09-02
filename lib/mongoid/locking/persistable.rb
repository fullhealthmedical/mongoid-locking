module Mongoid
  module Locking
    module Persistable # :nodoc:
      # Overrides the default Mongoid::Persistable#persist_atomic_operations
      # to:
      # - include the lock_version in the atomic selector
      # - increment the lock_version in the atomic updates
      def persist_atomic_operations(operations)
        return unless persisted? && operations.present?

        selector = _add_lock_version_to_selector(atomic_selector)
        _update_one_locked(_root.collection, selector, operations)
      end
    end
  end
end
