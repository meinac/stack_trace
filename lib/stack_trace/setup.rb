# frozen-string-literal: true

module StackTrace
  class Setup
    IGNORED_METHODS_REGEX = /^(?:_traced_|send)/

    class << self
      def call(modules)
        modules.each { |mod, method_names| setup_module(mod, method_names) }
      end

      private

      def setup_module(mod, method_names)
        mod.extend(Spy)
        mod.stack_trace_setup = new(mod, method_names)
        mod.stack_trace_setup.setup_existing_methods
      end
    end

    def initialize(mod, method_names)
      self.mod = mod
      self.method_names = method_names
    end

    def setup_existing_methods
      traced_methods.each do |traced_method|
        setup_method(traced_method) if has_method?(traced_method)
      end
    end

    def setup_method(method_name)
      return unless should_override?(method_name)

      overridden_methods << method_name
      define_trace_method(method_name)
    end

    private

    def traced_methods
      method_names == :all ? all_traceable_methods : method_names
    end

    def all_traceable_methods
      mod_methods.reject { |m| m =~ IGNORED_METHODS_REGEX }
    end

    def mod_methods
      mod.instance_methods + [:initialize]
    end

    def has_method?(method_name)
      mod_methods.include?(method_name)
    end

    def should_override?(method_name)
      traced_method?(method_name) && !overridden?(method_name)
    end

    attr_accessor :mod, :overridden_methods, :method_names

    def traced_method?(method_name)
      traced_methods.include?(method_name)
    end

    def overridden?(method_name)
      overridden_methods.include?(method_name)
    end

    def overridden_methods
      @overridden_methods ||= []
    end

    def define_trace_method(method_name)
      traced_method_name = traced_method_name(method_name)
      mod.alias_method(traced_method_name, method_name)
      params = mod.instance_method(method_name).parameters

      mod.define_method(method_name) do |*args|
        Trace.track(method_name, params: params, args: args.dup) { send(traced_method_name, *args) }
      end
    end

    def traced_method_name(original_method_name)
      "_traced_#{original_method_name}"
    end
  end
end
