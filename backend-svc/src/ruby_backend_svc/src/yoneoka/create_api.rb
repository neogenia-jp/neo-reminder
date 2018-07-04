require_relative './base_api'

module Yoneoka
  class CreateApi < BaseApi
    # 実行
    # @param json_data [JSON] 送られてきたJSONデータ
    # @return [String]
    def run(json_data)
      {created_at: @data_accessor.create(json_data['options'])}
    end
  end
end