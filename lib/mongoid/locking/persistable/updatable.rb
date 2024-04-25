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

              # The following code applies updates which would cause
              # path conflicts in MongoDB, for example when changing attributes
              # of foo.0.bars while adding another foo. Each conflicting update
              # is applied using its own write.
              #
              # TODO: MONGOID-5026: reduce the number of writes performed by
              # more intelligently combining the writes such that there are
              # fewer conflicts.
              conflicts.each_pair do |modifier, changes|
                # Group the changes according to their root key which is
                # the top-level association name.
                # This handles at least the cases described in MONGOID-4982.
                conflicting_change_groups = changes.group_by do |key, _|
                  key.split(".", 2).first
                end.values

                # Apply changes in batches. Pop one change from each
                # field-conflict group round-robin until all changes
                # have been applied.
                while batched_changes = conflicting_change_groups.map(&:pop).compact.to_h.presence
                  coll.find(selector).update_one(
                    positionally(selector, modifier => batched_changes),
                    session: _session
                  )
                end
              end
            end
          end
        end
      end
    end
  end
end
