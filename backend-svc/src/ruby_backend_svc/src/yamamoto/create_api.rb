module Yamamoto
  class CreateApi < BaseApi
    # 実行
    # @param json_data [JSON] 送られてきたJSONデータ
    # @return [String]
    def run(json_data)
      result = {}

      begin
        @data_accessor.create(json_data["options"].to_s)
        result[:status] = 'ok'
        result[:message] = ''
      rescue => e
        result[:status] = 'error'
        result[:message] = e.message
      end

      result.to_json
    end
  end
end

