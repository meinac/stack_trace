# frozen-string-literal: true

require "securerandom"

module StackTrace
  class Trace
    TRACE_START_EVENTS = %i(call c_call).freeze
    TRACE_END_EVENTS = %i(return c_return).freeze
    TRACE_RAISE_EVENT = :raise

    class << self
      def track(trace_point)
        current.add(trace_point) if trackable?(trace_point)
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

      private

      def trackable?(trace_point)
        trace_point.defined_class.trace_method?(trace_point.method_id)
      end
    end

    attr_reader :uuid, :spans

    def initialize
      @uuid = SecureRandom.uuid
      @spans = []
    end

    def add(trace_point)
      case trace_point.event
      when *TRACE_START_EVENTS
        create_new_span(trace_point)
      when *TRACE_END_EVENTS
        close_current_span(trace_point)
      else
        apply_exception_to_current_span(trace_point)
      end
    end

    def as_json
      {
        uuid: uuid,
        spans: spans.map(&:as_json)
      }
    end

    def <<(span)
      spans << span
    end

    private

    def create_new_span(trace_point)
      span = Span.start_from(trace_point, container)
      container << (@active_span = span)
    end

    def close_current_span(trace_point)
      @active_span = @active_span&.close(trace_point)
    end

    def apply_exception_to_current_span(trace_point)
      @active_span.exception = trace_point.raised_exception
    end

    def container
      @active_span || self
    end
  end
end
