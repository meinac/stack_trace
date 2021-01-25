# frozen-string-literal: true

module StackTrace
  class Persistence
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
        Dir.mkdir(root_path) unless Dir.exist?(root_path)
      end

      def tracing_file_path
        File.join(root_path, trace_file_name)
      end

      def trace_file_name
        Time.now.strftime('%d_%m_%Y_%H_%M_%S.json')
      end

      def root_path
        StackTrace.configuration.output_dir
      end
    end
  end
end
