
class Exception
  def pretty_log
    ["#{self.class}: #{self.to_s}", *self.backtrace.take(16)].join("\n\t")
  end
end