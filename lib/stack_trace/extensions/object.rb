# frozen-string-literal: true

module StackTrace
  module Extensions
    module Object
      def stack_trace_id
        "#<#{self.class.name}:#{format('%#016x', (object_id << 1))}>"
      end
    end
  end
end

Object.include(StackTrace::Extensions::Object)
