# frozen-string-literal: true

module StackTrace
  module Spy
    module EigenClass
      include Base

      def self.extended(mod)
        mod.include(InstanceMethods)
      end

      module InstanceMethods
        def stack_trace_id
          inspect
        end
      end
    end
  end
end
