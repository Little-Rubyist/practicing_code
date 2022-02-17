# 仕事で使っているcore_ext
class String
  def to_bool
    return self if self.class.is_a?(TrueClass) || self.class.is_a?(FalseClass)

    if self =~ /^(true|false)$/
      return true if Regexp.last_match(1) == 'true'
      return false if Regexp.last_match(1) == 'false'
    else
      raise NoMethodError, "undefined method `to_bool' for '#{self}'"
    end
  end
end

class Integer
  def with_tax
    (self * 1.1).floor
  end
end

class Time
  class << self
    def previous_first_date
      current.beginning_of_month.prev_month
    end
  end
end

