# frozen-string-literal: true

require "json"
require "erb"

module StackTrace
  module Presenter
    class Html
      include ERB::Util

      attr_reader :erb, :trace

      def initialize(trace)
        erb_file = File.expand_path "./public/main.erb"
        @erb = ERB.new(File.read(erb_file))
        @trace = trace
      end

      def span_row(span, class_id = 0)
        <<-HTML
          <tr class="collapsed" data-bs-toggle="collapse" aria-expanded="false"  data-bs-target="#demo#{class_id}">
            <td>  #{html_escape(span[:receiver])} </td>
            <td>  #{html_escape(span[:method_name])} </td>
            <td>  #{html_escape(span[:arguments])} </td>
            <td>  #{html_escape(span[:value])} </td>
            <td>  #{html_escape(span[:exception])} </td>
            <td>  #{html_escape(span[:time])} </td>
          </tr>
        HTML
      end

      def span_child_row(span, parent_class_id)
        <<-HTML
          <tr id=demo#{parent_class_id} class="accordion-collapse collapse">
            <td>  #{html_escape(span[:receiver])} </td>
            <td>  #{html_escape(span[:method_name])} </td>
            <td>  #{html_escape(span[:arguments])} </td>
            <td>  #{html_escape(span[:value])} </td>
            <td>  #{html_escape(span[:exception])} </td>
            <td>  #{html_escape(span[:time])} </td>
          </tr>
        HTML
      end

      def print_table(span, idx)
        return span_row(span, idx) if span[:spans].empty?

        iterate_tree(span, idx)
      end

      # rubocop:disable Metrics/MethodLength
      def iterate_tree(node, id_idx)
        queue = []
        res = []
        queue.push(node)

        until queue.empty?
          n = queue.shift

          if n[:spans].size.zero?
            id_idx += 1
          else
            res << span_row(n, id_idx)
          end

          n[:spans].each do |child|
            queue.push(child)
            res << span_child_row(child, id_idx)
          end
        end

        res.join("")
      end
      # rubocop:enable Metrics/MethodLength

      def content
        erb.result(binding)
      end
    end
  end
end
