module Yamamoto
  class EditApi < BaseApi

    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)
      # リマインダーを完了する
      result = {}
      begin
        @data_accessor.create(json_data['options'], json_data['options']['id'])
        result[:status] = 'ok'
        result[:message] = ''
        result[:created_at] = Time.now
      rescue => e
        result[:status] = 'error'
        result[:message] = e.message
        result[:created_at] = ''
      end
      result
    end
  end
end

