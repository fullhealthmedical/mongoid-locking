module Mongoid
  module Locking
    module Association
      module Embedded
        module Batchable # :nodoc:
          # Get the selector for executing atomic operations on the collection.
          #
          # @api private
          #
          # @example Get the selector.
          #   batchable.selector
          #
          # @return [ Hash ] The atomic selector.
          #
          # @since 3.0.0
          #
          # ---
          #
          # Mongoid memoizes the atomic selector, which is not compatible with
          # Mongoid::Locking. For subsequent saves, the lock_version needs to be
          # updated, so the atomic selector needs to be regenerated.
          def selector
            _base.atomic_selector
          end
        end
      end
    end
  end
end
