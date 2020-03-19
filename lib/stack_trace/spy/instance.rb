# frozen-string-literal: true

module StackTrace
  module Spy
    module Instance
      attr_accessor :stack_trace_setup, :stack_trace_name

      def self.extended(mod)
        mod.include(InstanceMethods)
      end

      def method_added(method_name)
        stack_trace_setup.setup_method(method_name)
      end

      def singleton_method_added(method_name)
        singleton_class.stack_trace_setup&.setup_method(method_name)
      end

      module InstanceMethods
        def stack_trace_id
          @stack_trace_id ||= "#{self.class.stack_trace_name}##{object_id}"
        end
      end
    end
  end
end
