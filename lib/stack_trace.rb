# frozen_string_literal: true

require_relative "stack_trace/version"
require_relative "stack_trace/configuration"
require_relative "stack_trace/argument_extractor"
require_relative "stack_trace/patch/object"
require_relative "stack_trace/patch/class"
require_relative "stack_trace/patch/nil_class"
require_relative "stack_trace/patch/numeric"
require_relative "stack_trace/patch/false_class"
require_relative "stack_trace/patch/true_class"
require_relative "stack_trace/patch/symbol"
require_relative "stack_trace/ext/stack_trace"

module StackTrace
  class << self
    def configure(&block)
      return false if configuration.frozen?

      block.call(configuration)

      Sidecar.run
      configuration.freeze
    end

    def trace(&block)
      start_trace # This creates the wrapper span

      trace_point.enable do
        block.call
      end

      complete_trace
    end

    private

    def configuration
      @configuration ||= Configuration.new
    end
  end
end
