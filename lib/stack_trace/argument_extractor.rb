# frozen_string_literal: true

module StackTrace
  class ArgumentExtractor
    class << self
      def extract(trace_point)
        trace_point.parameters
                  .map(&:last)
                  .each_with_object({}) do |parameter, memo|
                    memo[parameter] = extract_argument(trace_point, parameter).st_name
                  end
      end

      private

      def extract_argument(trace_point, parameter)
        trace_point.binding.eval(parameter.to_s)
      rescue Exception # SyntaxError can happen as we are calling `eval` here!
      end
    end
  end
end
