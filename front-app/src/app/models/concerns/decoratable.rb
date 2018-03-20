module Decoratable
  def decorate!
    ActiveDecorator::Decorator.instance.decorate(self) unless decorated?
    self
  end

  def decorated?
    singleton_class.ancestors.find {|klass| klass == ActiveDecorator::Helpers}
  end
end

