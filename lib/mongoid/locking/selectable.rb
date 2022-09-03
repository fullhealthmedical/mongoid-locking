module Mongoid
  module Locking
    module Selectable # :nodoc:
      # Overrides the default Mongoid::Selectable#atomic_selector to not memoize
      # its result.
      #
      # It is required when saving the same object multiple times in a row.
      def atomic_selector
        embedded? ? embedded_atomic_selector : root_atomic_selector
      end

      # https://github.com/mongodb/mongoid/blob/e03120a56894bc773dcf1e51209eb2f3e6f2b61f/lib/mongoid/selectable.rb#L55
      def root_atomic_selector
        { "_id" => id, "lock_version" => lock_version }
      end
    end
  end
end
