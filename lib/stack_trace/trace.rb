# frozen-string-literal: true

module StackTrace
  class Trace
    class << self
      def track(method_name, *args)
        span = current.add(method_name, *args)
        span.value = yield
      rescue StandardError => e
        span&.exception = e
        raise e
      ensure
        span&.close
      end

      def start
        @current = new
      end

      def current
        @current ||= new
      end

      def as_json
        current.as_json
      end
    end

    attr_reader :spans

    def initialize
      @spans = []
    end

    def add(method_name, *args)
      add_to_active_span(method_name, *args) || create_new_span(method_name, *args)
    end

    def as_json
      { spans: spans.map(&:as_json) }
    end

    private

    def add_to_active_span(method_name, *args)
      return unless @current_span&.open?

      @current_span.add(method_name, *args)
    end

    def create_new_span(method_name, *args)
      (spans << @current_span = Span.new(method_name, *args)) && @current_span
    end
  end
end
