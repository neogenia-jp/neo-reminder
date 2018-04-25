require_relative './base_api'

module Yamamoto
  class CreateApi < BaseApi
    # 実行
    # @param json_data [JSON] 送られてきたJSONデータ
    # @return [String]
    def run(json_data)
      result = {}

      begin
        data = @data_accessor.create(json_data['options'])
        result[:status] = 'ok'
        result[:message] = ''
        result[:created_at] = data['created_at']
      rescue => e
        result[:status] = 'error'
        result[:message] = e.message
        result[:created_at] = ''
      end

      result
    end
  end
end

