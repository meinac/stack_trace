# frozen_string_literal: true

class Object
  def st_name
    "#{self.class.name}##{object_id}"
  end
end
