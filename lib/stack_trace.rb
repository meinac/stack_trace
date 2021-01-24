# frozen-string-literal: true

require "stack_trace/configuration"
require "stack_trace/extensions/module"
require "stack_trace/extensions/object"
require "stack_trace/extensions/active_record/relation"
require "stack_trace/persistence"
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

      Trace.trace { yield }
    end

    def trace_point
      @trace_point ||= TracePoint.new(*TRACED_EVENTS) { |tp| Trace.track(tp) }
    end

    # This is necessary to find the source location
    # of all the modules/classes defined.
    def setup!
      TracePoint.new(:class) do |tp|
        tp.binding.eval <<~RUBY
          self.stack_trace_source_location = binding.source_location.first
        RUBY
      end.enable
    end
  end
end

StackTrace.setup!
