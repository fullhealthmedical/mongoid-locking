module Mongoid
  module Locking
    ##
    # Gives the ability to retry a block of code a specified number of times
    # when a Mongoid::StaleObjectError is raised.
    module Retry
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
