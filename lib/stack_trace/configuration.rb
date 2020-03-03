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
  end
end
