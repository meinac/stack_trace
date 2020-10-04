# frozen-string-literal: true

require "stack_trace/configuration"
require "stack_trace/module_extensions"
require "stack_trace/setup"
require "stack_trace/span"
require "stack_trace/trace"
require "stack_trace/version"

module StackTrace
  TRACED_EVENTS = %i(call c_call return c_return raise).freeze

  class << self
    def configure
      yield configuration
      trace_point.enable
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def trace
      return unless block_given?

      Trace.start
      yield
    end

    def current
      Trace.current
    end

    def as_json
      Trace.as_json
    end

    def trace_point
      @trace_point ||= TracePoint.new(*TRACED_EVENTS) { |tp| Trace.track(tp) }
    end
  end
end

TracePoint.new(:class) do |tp|
  tp.binding.eval <<~RUBY
    self.stack_trace_source_location = __FILE__
  RUBY
end.enable
