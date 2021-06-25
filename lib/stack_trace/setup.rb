# frozen-string-literal: true

module StackTrace
  class Setup
    class << self
      def trackable?(mod, method_id)
        store[mod].trace?(method_id)
      end

      # We can not store this information
      # in the module itself for the frozen
      # modules.
      def store
        @store ||= Hash.new do |h, k|
          h[k.singleton_class] = new(k, :class_methods)
          h[k] = new(k, :instance_methods)
        end
      end
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
        method_config != :skip_inherited || klass.instance_methods(false).include?(method_id)
      when Regexp
        method_id =~ method_config
      end
    end

    def method_config
      @method_config ||= config[1].fetch(context, [])
    end
  end
end
