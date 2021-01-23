# frozen-string-literal: true

module StackTrace
  module Extensions
    module ActiveRecord
      module Relation
        # `ActiveRecord::Relaton#inspect` can fire a SQL query therefore,
        # we can't use the original inspect for those kind of objects!
        # TODO: Find a way to do it without changing the behavior of ActiveRecord.
        def inspect
          stack_trace_id
        end
      end
    end
  end
end

ActiveRecord::Relation.prepend(StackTrace::Extensions::ActiveRecord::Relation) if defined?(ActiveRecord)
