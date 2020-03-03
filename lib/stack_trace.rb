# frozen-string-literal: true

require "stack_trace/configuration"
require "stack_trace/setup"
require "stack_trace/span"
require "stack_trace/spy"
require "stack_trace/trace"
require "stack_trace/version"

module StackTrace
  def self.configure
    yield configuration
    setup!
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.setup!
    configuration.modules.each { |mod, method_names| Setup.call(mod, method_names) }
  end

  def self.trace
    return unless block_given?

    Trace.start
    yield
  end
end
