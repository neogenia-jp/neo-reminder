require_relative './base_api'

module Yoneoka
  class EditApi < BaseApi

    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)
      # リマインダーを更新する
      edit_id = json_data['options']['id']
      @data_accessor.create(json_data['options'], edit_id)
      {created_at: @data_accessor.read(edit_id)['created_at']}
    end
  end
end
