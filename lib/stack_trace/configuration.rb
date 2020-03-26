# frozen-string-literal: true

module StackTrace
  class Configuration
    CONFIG_ATTRIBUTES = {
      enabled: false,
      modules: {},
    }

    attr_writer *CONFIG_ATTRIBUTES.keys

    CONFIG_ATTRIBUTES.each do |attr_name, default_value|
      define_method(attr_name) do
        instance_variable_get("@#{attr_name}") || default_value
      end
    end

    def for(klass)
      modules.find { |module_name_conf, _| config_for_class?(module_name_conf, klass) }
    end

    private

    def config_for_class?(config, klass)
      case config
      when Regexp
        klass.name =~ config
      when Hash
        match_hash_config(config, klass)
      else
        [config].flatten.include?(klass)
      end
    end

    def match_hash_config(config, klass)
      inherits_config?(klass, config) || path_config?(klass, config)
    end

    def inherits_config?(klass, inherits: nil, **)
      inherits &&
        klass.ancestors.include?(inherits) &&
        klass != inherits
    end

    def path_config?(klass, path: nil, **)
      path &&
        klass.stack_trace_source_location &&
        klass.stack_trace_source_location.match(path)
    end
  end
end
