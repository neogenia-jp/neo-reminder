class EmailValidator < ActiveModel::EachValidator
  # TODO 正規表現は今のPHPのに合わせる
  MAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/

  def validate_each(record, attribute, value)
    unless value =~ MAIL_REGEX
      record.errors.add attribute, (options[:message] || "is not an email")
    end
  end
end
