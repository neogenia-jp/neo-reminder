require 'time'
require_relative './base_api'

module Yamamoto
  class FinishApi < BaseApi

    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)
      # リマインダーを完了する
      remindar = @data_accessor.read(json_data['options']['id'])
      time = Time.now.iso8601
      remindar['finished_at'] = time

      result = {}
      begin
        @data_accessor.update(remindar, json_data['options']['id'])
        result[:status] = 'ok'
        result[:message] = ''
        result[:finished_at] = time
      rescue => e
        result[:status] = 'error'
        result[:message] = e.message
        result[:finished_at] = ''
      end
      result
    end
  end
end

