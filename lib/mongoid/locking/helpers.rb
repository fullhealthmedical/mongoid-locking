module Mongoid
  module Locking
    module Helpers # :nodoc:
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
  end
end
