require 'time'
require_relative './base_api'

module Yoneoka
  class FinishApi < BaseApi

    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)
      # リマインダーを完了する
      time = Time.now.iso8601
      contents = {'finished_at': time}

      @data_accessor.update(contents, json_data['options']['id'])
      {finished_at: time}
    end
  end
end

