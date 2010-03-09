# 
class Object
  # TODO: don't add if already defined
  def metaclass
    class << self
      self
    end
  end
end