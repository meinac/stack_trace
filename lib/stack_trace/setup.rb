# frozen-string-literal: true

module StackTrace
  class Setup
    def self.call(klass)
      klass.singleton_class.stack_trace_setup = new(klass, :class_methods)
      klass.stack_trace_setup = new(klass, :instance_methods)
    end

    def initialize(klass, context)
      self.klass = klass
      self.context = context
    end

    def trace?(method_id)
      enabled? && traced_method?(method_id)
    end

    private

    attr_accessor :klass, :context

    def enabled?
      defined?(@enabled) ? @enabled : (@enabled = !config.nil?)
    end

    def config
      @config ||= StackTrace.configuration.for(klass)
    end

    def traced_method?(method_id)
      method_lookup[method_id]
    end

    def method_lookup
      @method_lookup ||= Hash.new { |lookup, method_id| lookup[method_id] = method_enabled?(method_id) }
    end

    def method_enabled?(method_id)
      case method_config
      when Array
        method_config.include?(method_id)
      when Symbol
        method_config != :skip_inherited || instance_methods(false).include?(method_id)
      when Regexp
        method_id =~ method_config
      end
    end

    def method_config
      @method_config ||= config[1].fetch(context, [])
    end
  end
end
