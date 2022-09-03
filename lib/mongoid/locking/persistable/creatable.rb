module Mongoid
  module Locking
    module Persistable
      module Creatable # :nodoc:
        def insert_as_embedded
          raise Errors::NoParent, self.class.name unless _parent

          if _parent.new_record?
            _parent.insert
          else
            selector = _parent.atomic_selector
            _update_one_locked(_root.collection, selector, positionally(selector, atomic_inserts))
          end
        end
      end
    end
  end
end
