module Util
  # %%% xxx %%%形式で記述されたテンプレートの置換処理を行うクラス
  class TemplateConverter
    PLACE_HOLDER_REGEXP = /%%% ([^%]+) %%%/o

    def self.convert(template, params)
      return nil if template.blank?
      return template unless params

      normalized = params.with_indifferent_access
      template.gsub(PLACE_HOLDER_REGEXP) do |m|
        key = Regexp.last_match(1)
        if normalized.has_key?(key)
          normalized[key]
        else
          m
        end
      end
    end
  end
end

