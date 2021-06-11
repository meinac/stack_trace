# frozen-string-literal: true

require "json"

RSpec.configuration.after(:suite) do
  StackTrace::Integration::Rspec.finish_tracing
end

RSpec.configuration.around(:each) do |example|
  trace = StackTrace.trace { example.run }

  StackTrace::Integration::Rspec.store_trace(example, trace)
end

module StackTrace
  module Integration
    class Rspec
      EXAMPLE_META_KEYS = %i[file_path line_number scoped_id description full_description].freeze
      FINAL_MESSAGE = <<~TEXT
        \e[1m
        StackTrace:

        Trace information is saved into \e[32m%<file_path>s\e[0m
        \e[22m
      TEXT

      class << self
        def finish_tracing
          Persistence.save(html_content, :html)
                     .then { |path| print_message(path) }
        end

        def store_trace(example, trace)
          examples << example_data(example, trace)
        end

        private

        def html_content
          Presenter::Html.new(examples).content
        end

        def examples
          @examples ||= []
        end

        def example_data(example, trace)
          example.metadata.slice(*EXAMPLE_META_KEYS)
                 .merge!(trace: trace.as_json)
        end

        def print_message(path)
          puts format(FINAL_MESSAGE, file_path: path)
        end
      end
    end
  end
end
