class String
  def to_camel_case
    split('_').map { |s| s.capitalize }.join
  end

  def to_snake_case
    scan(/[A-Z][a-z]+/).map { |s| s.downcase }.join('_')
  end
end
