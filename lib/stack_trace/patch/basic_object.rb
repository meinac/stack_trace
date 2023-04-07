# frozen_string_literal: true

class BasicObject
  def st_name
    "#{self.class.name}:#{format('%#016x', (object_id << 1))}>"
  end
end
