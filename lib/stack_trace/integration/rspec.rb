# frozen-string-literal: true

require "json"

RSpec.configuration.before(:suite) do
  StackTrace::Integration::Rspec.create_tracing_directory
end

RSpec.configuration.after(:suite) do
  StackTrace::Integration::Rspec.finish_tracing
end

RSpec.configuration.around(:each) do |example|
  trace = StackTrace.trace { example.run }

  StackTrace::Integration::Rspec.save_trace(example, trace)
end

module StackTrace
  module Integration
    class Rspec
      EXAMPLE_META_KEYS = %i(file_path line_number scoped_id description full_description)
      FINAL_MESSAGE = <<~TEXT
        \e[1m
        StackTrace:

        Trace information is saved into \e[32m%{file_path}\e[0m
        \e[22m
      TEXT

      class << self
        def create_tracing_directory
          Dir.mkdir(tracing_dir_path) unless Dir.exist?(tracing_dir_path)
        end

        def finish_tracing
          save_examples
          print_message
        end

        def save_trace(example, trace)
          examples << example_data(example, trace)
        end

        private

        def examples
          @examples ||= []
        end

        def save_examples
          File.write(tracing_file_path, examples.to_json)
        end

        def tracing_file_path
          File.join(tracing_dir_path, trace_file_name)
        end

        def tracing_dir_path
          File.expand_path("stack_trace")
        end

        def trace_file_name
          @trace_file_name ||= Time.now.strftime('%d_%m_%Y %H_%M_%S.json')
        end

        def example_data(example, trace)
          example.metadata.slice(*EXAMPLE_META_KEYS)
                          .merge!(trace: trace.as_json)
        end

        def print_message
          puts format(FINAL_MESSAGE, file_path: tracing_file_path)
        end
      end
    end
  end
end
