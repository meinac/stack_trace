# frozen-string-literal: true

module StackTrace
  class Span
    attr_accessor :value, :exception
    attr_reader :method_name, :args, :spans

    def initialize(method_name, *args)
      self.started_at = Time.now.to_f
      self.method_name = method_name
      self.args = args
      self.spans = []
    end

    def add(method_name, *args)
      (spans << span = Span.new(method_name, *args)) && span
    end

    def close
      @finished_at = Time.now.to_f
      @closed = true
    end

    def open?
      !@closed
    end

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

    def as_json
      {
        method_name: method_name,
        arguments: args,
        value: value,
        exception: exception,
        time: time,
        spans: spans.map(&:as_json)
      }
    end

    private

    attr_accessor :started_at, :finished_at
    attr_writer :method_name, :args, :spans

    def time_ns
      (finished_at - started_at) * 1_000_000_000
    end
  end
end
