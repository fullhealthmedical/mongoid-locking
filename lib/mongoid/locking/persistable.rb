module Mongoid
  module Locking
    module Persistable # :nodoc:
      include ::Mongoid::Locking::Persistable::Creatable
      include ::Mongoid::Locking::Persistable::Updatable

      # Overrides the default Mongoid::Persistable#persist_atomic_operations
      # to:
      # - include the lock_version in the atomic selector
      # - increment the lock_version in the atomic updates
      def persist_atomic_operations(operations)
        return unless persisted? && operations.present?

        selector = atomic_selector
        _update_one_locked(_root.collection, selector, operations)
      end

      private

      def _update_one_locked(collection, selector, updates)
        if _locking?
          updates["$inc"] ||= {}
          updates["$inc"]["lock_version"] = 1
        end

        result = collection.find(selector).update_one(positionally(selector, updates), session: _session)

        if _locking?
          _assert_updated(result)
          _increase_lock_version
        end

        result
      end

      def _assert_updated(result)
        raise Mongoid::StaleObjectError, self.class.name.try(:downcase) if result.n < 1
      end

      def _increase_lock_version
        doc = embedded? ? _root : self

        doc.lock_version = (doc.lock_version || 0) + 1
        doc.remove_change('lock_version')
      end

      def _locking?
        klass = embedded? ? _root.class : self.class

        klass.included_modules.include?(::Mongoid::Locking)
      end
    end
  end
end
