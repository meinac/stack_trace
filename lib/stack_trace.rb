# frozen-string-literal: true

require "stack_trace/version"
require "stack_trace/span"
require "stack_trace/trace"

module StackTrace
  def trace(*method_names)
    self.traced_methods = method_names
  end

  def method_added(method_name)
    return unless should_override?(method_name)

    overridden_methods << method_name
    define_trace_method(method_name)
  end

  private

  attr_accessor :traced_methods

  def should_override?(method_name)
    traced_methods.include?(method_name) && !overridden_methods.include?(method_name)
  end

  def overridden_methods
    @overridden_methods ||= []
  end

  def define_trace_method(method_name)
    traced_method_name = traced_method_name(method_name)
    alias_method(traced_method_name, method_name)

    define_method(method_name) do |*args|
      Trace.track(method_name, *args) { send(traced_method_name, *args) }
    end
  end

  def traced_method_name(original_method_name)
    "_traced_#{original_method_name}"
  end
end
