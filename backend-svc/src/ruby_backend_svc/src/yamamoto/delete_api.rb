require_relative './base_api'

module Yamamoto
  class DeleteApi < BaseApi

    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)
      # リマインダーを完了する
      result = {}
      begin
        @data_accessor.delete(json_data['options']['id'])
        result[:status] = 'ok'
        result[:message] = ''
      rescue => e
        result[:status] = 'error'
        result[:message] = e.message
      end
      result
    end
  end
end

