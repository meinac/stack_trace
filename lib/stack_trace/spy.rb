# frozen-string-literal: true

module StackTrace
  module Spy
    attr_accessor :stack_trace_setup

    def self.extended(mod)
      mod.include(InstanceMethods)
    end

    def method_added(method_name)
      stack_trace_setup.setup_method(method_name)
    end

    module InstanceMethods
      def stack_trace_id
        @stack_trace_id ||= "#{self.class}##{object_id}"
      end
    end
  end
end
