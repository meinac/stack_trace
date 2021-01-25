# frozen-string-literal: true

require 'objspace'

module StackTrace
  class Utils
    class << self
      def monotonic_time
        Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
      end

      def object_counts
        return {} unless StackTrace.configuration.trace_memory

        ObjectSpace.count_objects
      end
    end
  end
end
