# frozen-string-literal: true

module StackTrace
  module ModuleExtensions
    attr_accessor :stack_trace_source_location
    attr_writer :stack_trace_setup

    def trace_method?(method_id)
      stack_trace_setup.trace?(method_id)
    end

    def stack_trace_setup
      @stack_trace_setup ||= Setup.call(self)
    end
  end
end

Module.include(StackTrace::ModuleExtensions)
