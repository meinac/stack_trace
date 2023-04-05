# frozen_string_literal: true

module StackTrace
  class ArgumentExtractor
    class << self
      def extract(trace_point)
        trace_point.parameters
                  .map(&:last)
                  .each_with_object({}) do |parameter, memo|
                    memo[parameter] = extract_argument(trace_point, parameter)
                  end
      end

      private

      def extract_argument(trace_point, parameter)
        trace_point.binding.eval(parameter.to_s).st_name
      rescue SyntaxError # This can happen as we are calling `eval` here!
      end
    end
  end
end
