require_relative './base_api'

module Yoneoka
  class EditApi < BaseApi

    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)
      # リマインダーを更新する
      edit_id = json_data['options']['id']
      {updated_at: @data_accessor.update(json_data['options'], edit_id) }
    end
  end
end
