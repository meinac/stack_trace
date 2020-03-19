# frozen-string-literal: true

module StackTrace
  module Spy
    module Base
      attr_accessor :stack_trace_setup

      def method_added(method_name)
        stack_trace_setup.setup_method(method_name) if stack_trace_setup
      end
    end
  end
end
