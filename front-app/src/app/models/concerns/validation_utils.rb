module ValidationUtils
  def add_error_if_blank(sym)
    val = block_given? ? yield : send(sym)
    errors.add(sym, :blank) if val.blank?
  end
end
