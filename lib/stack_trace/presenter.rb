# frozen-string-literal: true

require "securerandom"
require "json"

module StackTrace
  module Presenter
    def as_json
      {
        uuid: uuid,
        spans: spans.map(&:as_json)
      }
    end

    def as_html
      html_content = Html.new([file_data]).content

      Persistence.save(html_content, :html)
    end

    def persist
      Persistence.save(file_data.to_json, :json)
    end

    private

    def file_data
      {
        file_path: caller_locations[1].absolute_path,
        line_number: caller_locations[1].lineno,
        scoped_id: nil,
        description: caller_locations[1].base_label,
        full_description: caller_locations[1].to_s,
        trace: as_json
      }
    end
  end
end
