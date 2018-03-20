class ZipValidator < ActiveModel::EachValidator
  ZIP_REGEX = /\A(?:\d{3})-?(?:\d{4})\z/

  def validate_each(record, attribute, value)
    unless value =~ ZIP_REGEX
      record.errors.add attribute, (options[:message] || "is not a zip")
    end
  end
end
