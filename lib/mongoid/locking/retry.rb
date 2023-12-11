module Mongoid
  module Locking
    ##
    # Gives the ability to retry a block of code a specified number of times
    # when a Mongoid::StaleObjectError is raised.
    module Retry
      def self.included(base)
        base.extend(ClassMethods)
      end

      ##
      # Retries the block of code a specified number of times when a
      # Mongoid::StaleObjectError is raised.
      #
      # This method will reload the document before each block execution.
      #
      # @example
      #   person = Person.find(existing.id)
      #   person.with_locking do
      #     person.update!(name: "Person 1 updated")
      #   end
      #
      # @param [ Integer ] max_retries The maximum number of times to retry
      #
      # @return [ Object ] The result of the block
      def with_locking(max_retries: 3)
        self.class.with_locking(max_retries: max_retries) do
          reload
          yield
        end
      end

      module ClassMethods # :nodoc:
        ##
        # Retries the block of code a specified number of times when a
        # Mongoid::StaleObjectError is raised.
        #
        # @example
        #   Person.with_locking do
        #     person = Person.find(existing.id)
        #     Person.update!(name: "Person 1 updated")
        #   end
        #
        # @param [ Integer ] max_retries The maximum number of times to retry
        #
        # @return [ Object ] The result of the block
        def with_locking(max_retries: 3)
          retries = 0

          begin
            yield
          rescue Mongoid::StaleObjectError
            raise if retries >= max_retries

            retries += 1
            retry
          end
        end
      end
    end
  end
end
