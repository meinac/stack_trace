# frozen-string-literal: true

require "stack_trace/configuration"
require "stack_trace/module_extensions"
require "stack_trace/setup"
require "stack_trace/span"
require "stack_trace/trace"
require "stack_trace/version"

module StackTrace
  TRACED_EVENTS = %i(call c_call return c_return raise).freeze

  def self.configure
    yield configuration
    trace_point.enable
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.trace
    return unless block_given?

    Trace.start
    yield
  end

  def self.trace_point
    @trace_point ||= TracePoint.new(*TRACED_EVENTS) { |tp| Trace.track(tp) }
  end
end
