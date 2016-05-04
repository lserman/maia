module Maia
  class DryRun < Message
    def title
      ''
    end

    def body
      ''
    end

    def dry_run?
      true
    end
  end
end
