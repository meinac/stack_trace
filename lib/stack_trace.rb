# frozen-string-literal: true

require "stack_trace/configuration"
require "stack_trace/param_matcher"
require "stack_trace/setup"
require "stack_trace/span"
require "stack_trace/spy/eigen_class"
require "stack_trace/spy/instance"
require "stack_trace/trace"
require "stack_trace/version"
require "stack_trace/inherited_callback"

module StackTrace
  def self.configure
    yield configuration
    Setup.call
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.trace
    return unless block_given?

    Trace.start
    yield
  end
end
