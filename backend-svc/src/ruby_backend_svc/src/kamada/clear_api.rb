require_relative './base_api'

module Kamada
  class ClearApi < BaseApi

    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)
      # リマインダーを完了する
      result = {}
      begin
        @data_accessor.clear(json_data['options']['target'])
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
