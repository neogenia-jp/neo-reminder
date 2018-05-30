require_relative './base_api'

module Kamada
  class ObserveApi < BaseApi

    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)
      result = {}
      begin
        list = @data_accessor.observe(json_data['options'])
        result[:status] = 'ok'
        result[:message] = 'xxxxxxxxx'
        result[:notifications] = list
      rescue => e
        result[:status] = 'error'
        result[:message] = e.message
      end
      result
    end
  end
end
