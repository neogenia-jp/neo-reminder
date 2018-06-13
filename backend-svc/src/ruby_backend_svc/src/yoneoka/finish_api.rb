require 'time'
require_relative './base_api'

module Yoneoka
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
      @data_accessor.update(remindar, json_data['options']['id'])
      result[:finished_at] = time
      result
    end
  end
end

