module Mongoid
  module Locking
    module Persistable
      module Updatable # :nodoc:
        # Overrides the default Mongoid::Persistable::Updatable#update_document
        # to:
        # - include the lock_version in the atomic selector
        # - increment the lock_version in the atomic updates
        def update_document(options = {})
          prepare_update(options) do
            updates, conflicts = init_atomic_updates
            unless updates.empty?
              coll = collection(_root)
              selector = atomic_selector
              _update_one_locked(coll, selector, updates)
              conflicts.each_pair do |key, value|
                coll.find(selector).update_one(positionally(selector, { key => value }), session: _session)
              end
            end
          end
        end
      end
    end
  end
end
