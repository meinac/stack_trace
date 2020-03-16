# frozen-string-literal: true

# TODO: This implementation can behave different than actual ruby behaviour
# so try to find a better way to match arguments with method params.
# I can check `rb_scan_args` function in C API later.
module StackTrace
  class ParamMatcher
    KEY_TYPES = %i(key keyreq keyrest)

    def self.match(params, args)
      new(params, args).match
    end

    # TODO: Maybe we shouldn't instantiate an object for each method call!
    def initialize(params, args)
      self.params = params
      self.args = args
    end

    def match
      params.each_with_object({}) do |(type, parameter), memo|
        memo[parameter] = extract_param(parameter, type).inspect
      end
    end

    private

    attr_accessor :params, :args

    def extract_param(parameter, type)
      case type
      when :opt, :req, :keyrest
        args.shift.inspect
      when :rest
        assign_kwargs? ? args.shift(args.length - 1) : args
      when :key, :keyreq
        args.first.is_a?(Hash) && args.first.fetch(parameter, nil)
      end
    end

    def assign_kwargs?
      has_kwargs? && args.last.is_a?(Hash)
    end

    def has_kwargs?
      params.any? { |type, _| KEY_TYPES.include?(type) }
    end
  end
end
