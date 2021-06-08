# frozen-string-literal: true

require "stringio"

module StackTrace
  class Persistence
    WRITE_BATCH_SIZE = 1_000

    class << self
      def save(data, extension)
        create_tracing_directory

        write_data(data, tracing_file_path(extension))
      end

      private

      def write_data(data, file_path)
        File.open(file_path, "w") do |f|
          StringIO.new(data).each(WRITE_BATCH_SIZE) { |d| f << d } && f.path
        end
      end

      def create_tracing_directory
        Dir.mkdir(root_path) unless Dir.exist?(root_path)
      end

      def tracing_file_path(extension)
        File.join(root_path, trace_file_name(extension))
      end

      def trace_file_name(extension)
        Time.now.strftime("%d_%m_%Y_%H_%M_%S.#{extension}")
      end

      def root_path
        StackTrace.configuration.output_dir
      end
    end
  end
end
