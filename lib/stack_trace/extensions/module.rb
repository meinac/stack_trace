# frozen-string-literal: true

module StackTrace
  module Extensions
    module Module
      attr_accessor :stack_trace_source_location

      def trace_method?(method_id)
        Setup.trackable?(self, method_id)
      end

      def stack_trace_id
        name || inspect
      end
    end
  end
end

Module.include(StackTrace::Extensions::Module)
