# frozen-string-literal: true

require "json"
require "erb"

module StackTrace
  module Presenter
    class Html
      LAYOUT_FILE = "./public/main.html.erb"

      attr_reader :trace

      def initialize(trace)
        @trace = trace
      end

      def content
        erb.result_with_hash({ trace_data: trace.to_json })
      end

      private

      def erb
        ERB.new(layout)
      end

      def layout
        File.read(layout_path)
      end

      def layout_path
        File.expand_path(LAYOUT_FILE)
      end
    end
  end
end
