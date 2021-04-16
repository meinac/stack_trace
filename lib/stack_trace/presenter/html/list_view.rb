
module StackTrace
  module Presenter
    module Html
      class ListView < AbstractView
       include ERB::Util

       attr_reader :erb, :spans, :uuid

       VIEW_FILE = File.expand_path './public/list.erb'

       def initialize(spans, uuid)
         @erb = ERB.new(File.read(VIEW_FILE))
         @spans = spans
         @uuid = uuid
       end

       def span_row(span, class_id=0)
         <<-HTML
          <tr class="collapsed" data-bs-toggle="collapse" aria-expanded="false"  data-bs-target="#demo#{class_id}">
            #{build_rows(span).join('')}
          </tr>
         HTML
       end

       def span_child_row(span, parent_class_id)
         <<-HTML
          <tr id=demo#{parent_class_id} class="accordion-collapse collapse">
            #{build_rows(span).join('')}
          </tr>
         HTML
       end

       def print_table(span, idx)
         return span_row(span, idx) if span[:spans].empty?

         iterate_tree(span, idx)
       end

       def build
        write_file("#{uuid}.html")
       end

       private

       def iterate_tree(node, id_idx)
         queue = []
         res = []
         queue.push(node)

         while(queue.size != 0)
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

         res.join('')
       end

       def build_rows(span)
        fields = {
          receiver: -> (val) { val },
          method_name: -> (val) { val },
          arguments: -> (val) { val },
          value: -> (val) { val },
          exception: -> (val) { val },
          time: -> (val) { val }
        }

        fields.map do |field, formatter|
          "<td>  #{html_escape(formatter.(span[field]))} </td>"
        end
       end

       def content
         erb.result(binding)
       end

       def write_file(output)
         File.write("list-#{output}", content)
       end
     end
    end
  end
end
