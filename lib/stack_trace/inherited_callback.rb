# frozen-string-literal: true

module StackTrace
  module InheritedCallback
    def inherited(klass)
      super
      Setup.inherited(klass)
    end
  end
end

Object.extend(StackTrace::InheritedCallback)
