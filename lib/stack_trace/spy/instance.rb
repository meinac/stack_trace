# frozen-string-literal: true

module StackTrace
  module Spy
    module Instance
      include Base

      attr_accessor :stack_trace_name

      def self.extended(mod)
        mod.include(InstanceMethods)
      end

      module InstanceMethods
        def stack_trace_id
          @stack_trace_id ||= "#{self.class.stack_trace_name}##{object_id}"
        end
      end
    end
  end
end
