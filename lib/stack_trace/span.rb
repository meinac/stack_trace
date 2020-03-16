# frozen-string-literal: true

module StackTrace
  class Span
    attr_accessor :value, :exception
    attr_reader :receiver, :method_name, :args, :spans

    def initialize(receiver, method_name, args)
      self.receiver = receiver
      self.started_at = Time.now.to_f
      self.method_name = method_name
      self.args = args
      self.spans = []
    end

    def add(receiver, method_name, args)
      (spans << span = Span.new(receiver, method_name, args)) && span
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
        receiver: receiver,
        method_name: method_name,
        arguments: args,
        value: value.inspect,
        exception: exception_as_json,
        time: time,
        spans: spans.map(&:as_json)
      }
    end

    private

    attr_accessor :started_at, :finished_at
    attr_writer :receiver, :method_name, :args, :spans

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
  end
end
