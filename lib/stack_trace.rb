# frozen-string-literal: true

require "stack_trace/configuration"
require "stack_trace/extensions/module"
require "stack_trace/extensions/object"
require "stack_trace/extensions/active_record/relation"
require "stack_trace/persistence"
require "stack_trace/presenter"
require "stack_trace/setup"
require "stack_trace/span"
require "stack_trace/trace"
require "stack_trace/version"

module StackTrace
  RB_METHOD_EVENTS = %i(call return raise).freeze
  C_METHOD_EVENTS = %i(c_call c_return raise).freeze

  class << self
    def configure
      yield configuration

      trace_point&.enable
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def trace
      return unless block_given?

      Trace.trace { yield }
    end

    def trace_point
      return if traced_events.empty?

      @trace_point ||= TracePoint.new(*traced_events) { |tp| Trace.track(tp) }
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

    private

    def traced_events
      @traced_events ||= begin
        [].tap do |events|
          events.append(*RB_METHOD_EVENTS) if configuration.ruby_calls
          events.append(*C_METHOD_EVENTS) if configuration.c_calls
        end.uniq
      end
    end
  end
end

StackTrace.setup!
