require_relative './base_api'

module Kamada
  class CreateApi < BaseApi
    # 実行
    # @param json_data [JSON] 送られてきたJSONデータ
    # @return [Hash]
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
        result[:created_at] = nil
      end

      result
    end
  end
end
