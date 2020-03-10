# frozen-string-literal: true

module StackTrace
  module Spy
    module Instance
      include Base

      def self.extended(mod)
        mod.include(InstanceMethods)
      end

      module InstanceMethods
        def stack_trace_id
          @stack_trace_id ||= "#{self.class.name}##{object_id}"
        end
      end
    end
  end
end
