# frozen-string-literal: true

module StackTrace
  class Setup
    # TODO: Change this logic later with a rubost one.
    IGNORED_METHODS_REGEX = /^(?:_traced_|send|stack_trace_id|class|object_id|inspect|stack_trace_name)/

    class << self
      def call(modules)
        modules.each { |mod, config| setup(mod, config) }
      end

      private

      def setup(mod, instance_methods: [], class_methods: [])
        setup_module(mod.name, mod, instance_methods, Spy::Instance)
        setup_module(mod.name, mod.singleton_class, class_methods, Spy::EigenClass)
      end

      def setup_module(mod_name, mod, method_names, spy_module)
        mod.extend(spy_module)
        mod.stack_trace_name = mod_name
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

    attr_accessor :mod, :method_names

    def should_override?(method_name)
      traced_method?(method_name) && !overridden?(method_name)
    end

    def traced_method?(method_name)
      traced_methods.include?(method_name)
    end

    def traced_methods
      case method_names
      when Array
        method_names
      when Symbol
        all_traceable_methods
      when Regexp
        all_matching_methods
      else
        raise "Only `Array`, `Symbol` or `Regexp` values are allowed for method_names"
      end
    end

    def has_method?(method_name)
      mod_methods.include?(method_name)
    end

    def all_matching_methods
      all_traceable_methods.select { |m| m =~ method_names }
    end

    def all_traceable_methods
      mod_methods.reject { |m| m =~ self.class::IGNORED_METHODS_REGEX }
    end

    def mod_methods
      mod.instance_methods(regular_methods?) + [:initialize]
    end

    def regular_methods?
      method_names =! :skip_inherited
    end

    def overridden?(method_name)
      overridden_methods.include?(method_name)
    end

    def overridden_methods
      @overridden_methods ||= []
    end

    def traced_method_name(original_method_name)
      "_traced_#{original_method_name}"
    end

    def define_trace_method(method_name)
      traced_method_name = traced_method_name(method_name)
      mod.alias_method(traced_method_name, method_name)
      params = mod.instance_method(method_name).parameters

      mod.define_method(method_name) do |*args, &block|
        Trace.track(stack_trace_id, method_name, params: params, args: args.dup) { send(traced_method_name, *args, &block) }
      end
    end
  end
end
