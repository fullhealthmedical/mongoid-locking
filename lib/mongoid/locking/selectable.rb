module Mongoid
  module Locking
    module Selectable # :nodoc:
      # Overrides the default Mongoid::Selectable#atomic_selector to not memoize
      # its result.
      #
      # It is required when saving the same object multiple times in a row.
      def atomic_selector(skip_lock_version: false)
        embedded? ? embedded_atomic_selector : root_atomic_selector(skip_lock_version: skip_lock_version)
      end

      # Get the atomic selector for a root document.
      #
      # @api private
      #
      # @example Get the root atomic selector.
      #   document.root_atomic_selector
      #
      # @return [ Hash ] The root document selector.
      #
      # @since 4.0.0
      # https://github.com/mongodb/mongoid/blob/e03120a56894bc773dcf1e51209eb2f3e6f2b61f/lib/mongoid/selectable.rb#L55
      def root_atomic_selector(skip_lock_version: false)
        return { "_id" => id, "lock_version" => lock_version }.merge!(shard_key_selector) unless skip_lock_version

        { "_id" => id }.merge!(shard_key_selector)
      end
    end
  end
end
