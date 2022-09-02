module Mongoid
  module Locking
    module Contextual
      # :nodoc:
      module Mongo
        # Update the documents for the provided method.
        #
        # @api private
        #
        # @example Update the documents.
        #   context.update_documents(attrs)
        #
        # @param [ Hash ] attributes The updates.
        # @param [ Symbol ] method The method to use.
        #
        # @return [ true, false ] If the update succeeded.
        def update_documents(attributes, method = :update_one, opts = {})
          return false unless attributes

          attributes = Hash[attributes.transform_keys { |k| klass.database_field_name(k.to_s) }]
          updates = attributes.__consolidate__(klass)
          updates["$inc"] ||= {}
          updates["$inc"]["lock_version"] = 1

          view.send(method, updates, opts)
        end
      end
    end
  end
end
