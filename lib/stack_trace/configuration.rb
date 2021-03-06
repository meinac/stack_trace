# frozen-string-literal: true

require "objspace"

module StackTrace
  class Configuration
    CONFIG_ATTRIBUTES = {
      enabled: false,
      modules: {},
      trace_parameters: false,
      trace_memory: false,
      output_dir: File.expand_path("stack_trace"),
      ruby_calls: true,
      c_calls: true
    }.freeze

    attr_writer(*CONFIG_ATTRIBUTES.keys)

    CONFIG_ATTRIBUTES.each do |attr_name, default_value|
      define_method(attr_name) do
        config_value = instance_variable_get("@#{attr_name}")

        config_value.nil? ? default_value : config_value
      end
    end

    def for(klass)
      config_holder = config_holder_for(klass)
      modules.find { |module_name_conf, _| config_for_class?(module_name_conf, config_holder) }
    end

    private

    # Configuration for StackTrace is done by specifying the class/module itself
    # so if the klass we receive here is a singleton_class, we should get the
    # class/module of that singleton_class first.
    def config_holder_for(klass)
      klass.singleton_class? ? ObjectSpace.each_object(klass).first : klass
    end

    def config_for_class?(config, klass)
      case config
      when Regexp
        klass.respond_to?(:name) && klass.name =~ config
      when Hash
        match_hash_config(config, klass)
      else
        [config].flatten.include?(klass)
      end
    end

    def match_hash_config(config, klass)
      inherits_config?(klass, **config) || path_config?(klass, **config)
    end

    def inherits_config?(klass, inherits: nil, **)
      inherits &&
        klass.respond_to?(:ancestors) &&
        klass.ancestors.include?(inherits) &&
        klass != inherits
    end

    def path_config?(klass, path: nil, **)
      path &&
        klass.respond_to?(:stack_trace_source_location) &&
        klass.stack_trace_source_location &&
        klass.stack_trace_source_location.match(path)
    end
  end
end
