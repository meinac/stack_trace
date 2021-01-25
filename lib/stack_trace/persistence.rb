# frozen-string-literal: true

module StackTrace
  class Persistence
    ROOT_PATH = File.expand_path("stack_trace")
    WRITE_BATCH_SIZE = 1_000

    class << self
      def save(data)
        create_tracing_directory

        File.open(tracing_file_path, "w") do |f|
          StringIO.new(data.to_json).each(WRITE_BATCH_SIZE) { |d| f << d } && f.path
        end
      end

      private

      def create_tracing_directory
        Dir.mkdir(ROOT_PATH) unless Dir.exist?(ROOT_PATH)
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
