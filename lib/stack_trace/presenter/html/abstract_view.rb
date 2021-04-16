require 'json'
require 'erb'

module StackTrace
  module Presenter
    module Html
        class AbstractView
            def build
              raise NotImplementedError, "subclass #{self.class} did not define #build"
            end
        end
    end
  end
end