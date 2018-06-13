require_relative './base_api'

module Yoneoka
  class DeleteApi < BaseApi

    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)
      # リマインダーを完了する
      @data_accessor.delete(json_data['options']['id'])
    end
  end
end

