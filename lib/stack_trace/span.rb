# frozen-string-literal: true

require 'objspace'

module StackTrace
  class Span
    class << self
      def start_from(trace_point, parent)
        new(
          receiver(trace_point),
          trace_point.method_id,
          extract_arguments(trace_point),
          parent
        )
      end

      private

      def receiver(trace_point)
        trace_point.binding.eval("self").to_s
      end

      def extract_arguments(trace_point)
        trace_point.parameters
                   .map(&:last)
                   .each_with_object({}) do |parameter, memo|
                      memo[parameter] = trace_point.binding.eval(parameter.to_s).inspect
                   end
      end
    end

    attr_writer :exception

    def initialize(receiver, method_name, args, parent)
      self.receiver = receiver
      self.method_name = method_name
      self.args = args
      self.parent = parent
      self.started_at = Time.now.to_f
      self.spans = []
      self.start_object_counts = ObjectSpace.count_objects
    end

    def <<(span)
      (spans << span) && span
    end

    def close(trace_point)
      self.value = trace_point.return_value.inspect
      self.finished_at = Time.now.to_f
      self.finish_object_counts = ObjectSpace.count_objects
      parent
    end

    def as_json
      {
        receiver: receiver,
        method_name: method_name,
        arguments: args,
        value: value,
        exception: exception_as_json,
        time: time,
        time_ms: time_ms,
        object_counts: object_counts,
        spans: spans.map(&:as_json)
      }
    end

    private

    attr_accessor :receiver, :method_name, :args, :value, :parent, :spans,
                  :started_at, :finished_at, :start_object_counts, :finish_object_counts
    attr_reader :exception

    def time
      case time_ns
      when 0..1_000
        "#{time_ns} ns"
      when 0..1_000_000
        "#{time_ns / 1_000} µs"
      when 0..1_000_000_000
        "#{time_ns / 1_000_000} ms"
      else
        "#{time_ns / 1_000_000_000} s"
      end
    end

    def exception_as_json
      return unless exception

      {
        message: exception.message,
        backtrace: exception.backtrace
      }
    end

    def time_ns
      (finished_at - started_at) * 1_000_000_000
    end

    def time_ms
      time_ns / 1_000_000
    end

    def object_counts
      finish_object_counts.each_with_object({}) do |(k, v), memo|
        memo[k] = v - start_object_counts[k]
      end
    end
  end
end
