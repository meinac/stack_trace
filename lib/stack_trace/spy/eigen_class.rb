# frozen-string-literal: true

module StackTrace
  module Spy
    module EigenClass
      attr_accessor :stack_trace_setup, :stack_trace_name
      alias_method :stack_trace_id, :stack_trace_name

      def self.extended(mod)
        mod.include(InstanceMethods)
      end

      module InstanceMethods
        attr_accessor :stack_trace_name
        alias_method :stack_trace_id, :stack_trace_name
      end
    end
  end
end
