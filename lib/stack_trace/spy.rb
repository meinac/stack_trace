# frozen-string-literal: true

module StackTrace
  module Spy
    attr_accessor :stack_trace_setup

    def method_added(method_name)
      stack_trace_setup.setup_method(method_name)
    end
  end
end
