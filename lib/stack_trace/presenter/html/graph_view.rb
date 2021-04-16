require 'graphviz'

module StackTrace
  module Presenter
    module Html
      class GraphView < AbstractView
       include ERB::Util

       attr_reader :erb, :spans, :uuid

       VIEW_FILE = File.expand_path './public/graph.erb'

       def initialize(spans, uuid)
         @erb = ERB.new(File.read(VIEW_FILE))
         @spans = spans
         @uuid = uuid
       end

       def print_table(span, idx)
         <<-HTML
           <tr>
             <td> <p class="accordion-button collapsed" data-bs-toggle="collapse" data-bs-target="#collapseOne" aria-expanded="false" aria-controls="collapseOne"> #{html_escape(span[:receiver])} </p>
               <div id="collapseOne" class="accordion-collapse collapse">
                  <div class="accordion-body">
                    <img src="./#{build_graph(span, idx)}">
                  </div>
               </div>
             </td>
             <td> <p> #{html_escape(span[:exception])} </p> </td>
           </tr>
         HTML
      end

       def build_graph(span, idx)
         root_graph = Graphviz::Graph.new("#{uuid}:#{idx}")
         iterate_tree(root_graph, span)
         Graphviz.output(root_graph, path: "#{root_graph.name}.svg", format: 'svg')

         "#{root_graph.name}.svg"
       end

       def iterate_tree(rg, node)
         queue = []
         queue.push(node)

         while(queue.size != 0)
           n = queue.shift
           rg = rg.add_node("#{n[:receiver]}#{n[:method_name]}") if n[:spans].size > 0

           n[:spans].each do |child|
             queue.push(child)
             rg.add_node("#{child[:receiver]}#{child[:method_name]}")
           end
         end
       end

       def build
        write_file("#{uuid}.html")
       end

       private

       def content
         erb.result(binding)
       end

       def write_file(output)
         File.write("graph-#{output}", content)
       end
     end
    end
  end
end
