require_relative './base_api'

module Kamada
  class EditApi < BaseApi

    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)
      # リマインダーを更新する
      edit_id = json_data['options']['id']
      result = {}
      begin
        @data_accessor.create(json_data['options'], edit_id)
        result[:status] = 'ok'
        result[:message] = ''
        result[:created_at] = @data_accessor.read(edit_id)['created_at']
      rescue => e
        result[:status] = 'error'
        result[:message] = e.message
        result[:created_at] = ''
      end
      result
    end
  end
end

