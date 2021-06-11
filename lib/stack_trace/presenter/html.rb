# frozen-string-literal: true

require "json"
require "erb"

module StackTrace
  module Presenter
    class Html
      LAYOUT_FILE = "../../public/main.html.erb"

      attr_reader :trace

      def initialize(trace)
        @trace = trace
      end

      def content
        erb.result_with_hash({ trace_data: trace_data })
      end

      private

      def trace_data
        # We shouldn't use `to_json` as it is overridden by ActiveSupport.
        JSON.generate(trace)
      end

      def erb
        ERB.new(layout)
      end

      def layout
        File.read(layout_path)
      end

      def layout_path
        File.expand_path(LAYOUT_FILE, root_path)
      end

      def root_path
        File.dirname(__dir__)
      end
    end
  end
end
