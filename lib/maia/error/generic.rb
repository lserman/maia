module Maia
  module Error
    class Generic < ::StandardError
      attr_accessor :payload
    end
  end
end
