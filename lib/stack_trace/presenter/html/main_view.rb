

module StackTrace
  module Presenter
    module Html
      class MainView < AbstractView
       include ERB::Util

       attr_reader :erb, :trace, :sub_views

       VIEW_FILE = File.expand_path './public/main.erb'

       def initialize(trace)
         @erb = ERB.new(File.read(VIEW_FILE))
         @trace = trace
         @sub_views = []
         add_subviews
       end

       def print_list(trace)
         <<-HTML
          <tr>
            <td> #{html_escape(trace[:uuid])} </td>
            <td> <a href= "list-#{html_escape(trace[:uuid])}.html"> List View</a> </td>
            <td> <a href= "graph-#{html_escape(trace[:uuid])}.html"> Graph View</a> </td>
          </tr>
         HTML
       end

       def build
        sub_views.each do |s|
          s.build
        end

        write_file
       end

       private

       def add_subviews
         sub_views << ListView.new(trace.fetch(:spans, []), trace[:uuid])
         sub_views << GraphView.new(trace.fetch(:spans, []), trace[:uuid])
       end

       def content
         erb.result(binding)
       end

       def write_file(output='main.html')
         File.write(output, content)
       end
     end
    end
  end
end
