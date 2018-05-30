require_relative './base_api'

module Kamada
  class DetailApi < BaseApi

    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)
      # リマインダーを取得する
      @data_accessor.read(json_data['options']['id'])
    end
  end
end
