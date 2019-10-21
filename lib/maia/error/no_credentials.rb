module Maia
  module Error
    class NoCredentials < Generic
      def initialize
        super 'No credentials were found for this gateway.'
      end
    end
  end
end
