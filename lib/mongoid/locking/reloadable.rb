# encoding: utf-8
module Mongoid
  module Locking
    # This module handles reloading behaviour of documents.
    #
    # @since 4.0.0
    module Reloadable

      # Reloads the +Document+ attributes from the database. If the document has
      # not been saved then an error will get raised if the configuration option
      # was set. This can reload root documents or embedded documents.
      #
      # @example Reload the document.
      #   person.reload
      #
      # @raise [ Errors::DocumentNotFound ] If the document was deleted.
      #
      # @return [ Document ] The document, reloaded.

      private

      # Reload the root document.
      #
      # @example Reload the document.
      #   document.reload_root_document
      #
      # @return [ Hash ] The reloaded attributes.
      #
      # @since 2.3.2
      # Starting from Mongoid version 7.2, the reload method now utilizes the
      # `atomic_selector` to locate the current document.
      #
      # As the lock_version can be disregarded during a reload, this method
      # has been overridden to bypass the lock version.
      def reload_root_document
        {}.merge(collection.find(atomic_selector(skip_lock_version: true)).read(mode: :primary).first || {})
      end
    end
  end
end
