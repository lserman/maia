module Maia
  class DryRun < Message
    def alert
      ''
    end

    def dry_run?
      true
    end
  end
end
