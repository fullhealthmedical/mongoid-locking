module Mongoid
  module Locking
    module Contextual
      # :nodoc:
      module Atomic
        # Execute an atomic $addToSet on the matching documents.
        #
        # @example Add the value to the set.
        #   context.add_to_set(members: "Dave", genres: "Electro")
        #
        # @param [ Hash ] adds The operations.
        #
        # @return [ nil ] Nil.
        def add_to_set(adds)
          _update_many_with_locking("$addToSet" => collect_operations(adds))
        end

        # Perform an atomic $addToSet/$each on the matching documents.
        #
        # @example Add the value to the set.
        #   context.add_each_to_set(members: ["Dave", "Bill"], genres: ["Electro", "Disco"])
        #
        # @param [ Hash ] adds The operations.
        #
        # @return [ nil ] Nil.
        def add_each_to_set(adds)
          _update_many_with_locking("$addToSet" => collect_each_operations(adds))
        end

        # Perform an atomic $bit operation on the matching documents.
        #
        # @example Perform the bitwise op.
        #   context.bit(likes: { and: 14, or: 4 })
        #
        # @param [ Hash ] bits The operations.
        #
        # @return [ nil ] Nil.
        def bit(bits)
          _update_many_with_locking("$bit" => collect_operations(bits))
        end

        # Perform an atomic $inc operation on the matching documents.
        #
        # @example Perform the atomic increment.
        #   context.inc(likes: 10)
        #
        # @param [ Hash ] incs The operations.
        #
        # @return [ nil ] Nil.
        def inc(incs)
          _update_many_with_locking("$inc" => collect_operations(incs))
        end

        # Perform an atomic $pop operation on the matching documents.
        #
        # @example Pop the first value on the matches.
        #   context.pop(members: -1)
        #
        # @example Pop the last value on the matches.
        #   context.pop(members: 1)
        #
        # @param [ Hash ] pops The operations.
        #
        # @return [ nil ] Nil.
        def pop(pops)
          _update_many_with_locking("$pop" => collect_operations(pops))
        end

        # Perform an atomic $pull operation on the matching documents.
        #
        # @example Pull the value from the matches.
        #   context.pull(members: "Dave")
        #
        # @note Expression pulling is not yet supported.
        #
        # @param [ Hash ] pulls The operations.
        #
        # @return [ nil ] Nil.
        def pull(pulls)
          _update_many_with_locking("$pull" => collect_operations(pulls))
        end

        # Perform an atomic $pullAll operation on the matching documents.
        #
        # @example Pull all the matching values from the matches.
        #   context.pull_all(:members, [ "Alan", "Vince" ])
        #
        # @param [ Hash ] pulls The operations.
        #
        # @return [ nil ] Nil.
        def pull_all(pulls)
          _update_many_with_locking("$pullAll" => collect_operations(pulls))
        end

        # Perform an atomic $push operation on the matching documents.
        #
        # @example Push the value to the matching docs.
        #   context.push(members: "Alan")
        #
        # @param [ Hash ] pushes The operations.
        #
        # @return [ nil ] Nil.
        def push(pushes)
          _update_many_with_locking("$push" => collect_operations(pushes))
        end

        # Perform an atomic $push/$each operation on the matching documents.
        #
        # @example Push the values to the matching docs.
        #   context.push_all(members: [ "Alan", "Fletch" ])
        #
        # @param [ Hash ] pushes The operations.
        #
        # @return [ nil ] Nil.
        def push_all(pushes)
          _update_many_with_locking("$push" => collect_each_operations(pushes))
        end

        # Perform an atomic $rename of fields on the matching documents.
        #
        # @example Rename the fields on the matching documents.
        #   context.rename(members: :artists)
        #
        # @param [ Hash ] renames The operations.
        #
        # @return [ nil ] Nil.
        def rename(renames)
          operations = renames.inject({}) do |ops, (old_name, new_name)|
            ops[old_name] = new_name.to_s
            ops
          end
          _update_many_with_locking("$rename" => collect_operations(operations))
        end

        # Perform an atomic $set of fields on the matching documents.
        #
        # @example Set the field value on the matches.
        #   context.set(name: "Depeche Mode")
        #
        # @param [ Hash ] sets The operations.
        #
        # @return [ nil ] Nil.
        #
        # @since 3.0.0
        def set(sets)
          _update_many_with_locking("$set" => collect_operations(sets))
        end

        # Perform an atomic $unset of a field on the matching documents.
        #
        # @example Unset the field on the matches.
        #   context.unset(:name)
        #
        # @param [ String | Symbol | Array<String|Symbol> | Hash ] args
        #   The name(s) of the field(s) to unset.
        #   If a Hash is specified, its keys will be used irrespective of what
        #   each key's value is, even if the value is nil or false.
        #
        # @return [ nil ] Nil.
        def unset(*args)
          fields = args.map { |a| a.is_a?(Hash) ? a.keys : a }
                       .__find_args__
                       .map { |f| [database_field_name(f), true] }
          view.update_many("$unset" => Hash[fields])
        end

        private

        def _update_many_with_locking(operations)
          if _locking?
            view.update_many(operations.merge("$inc" => { "lock_version" => 1 }))
          else
            view.update_many(operations)
          end
        end

        def _locking?
          @klass.included_modules.include?(Mongoid::Locking)
        end
      end
    end
  end
end
