# frozen-string-literal: true

module StackTrace
  class Persistence
    ROOT_PATH = File.expand_path("stack_trace")

    class << self
      def create_tracing_directory
        Dir.mkdir(ROOT_PATH) unless Dir.exist?(ROOT_PATH)
      end

      def save(data)
        create_tracing_directory

        File.open(tracing_file_path, "w") { |f| f << data.to_json }.path
      end

      def tracing_file_path
        File.join(ROOT_PATH, trace_file_name)
      end

      def trace_file_name
        Time.now.strftime('%d_%m_%Y_%H_%M_%S.json')
      end
    end
  end
end
