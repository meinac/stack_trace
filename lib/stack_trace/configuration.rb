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
        klass.ancestors.include?(config[:inherits]) && klass != config[:inherits]
      else
        [config].flatten.include?(klass)
      end
    end
  end
end
