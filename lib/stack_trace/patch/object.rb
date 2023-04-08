# frozen_string_literal: true

class Object
  def st_name
    "#{self.class.name}:#{format('%#016x', (object_id << 1))}>"
  end
end
