# frozen-string-literal: true

module StackTrace
  module ModuleExtensions
    attr_accessor :stack_trace_source_location

    def trace_method?(method_id)
      Setup.trackable?(self, method_id)
    end
  end
end

Module.include(StackTrace::ModuleExtensions)
