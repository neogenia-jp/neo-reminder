module Yamamoto
  class FinishApi < BaseApi

    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)
      # リマインダーを完了する
      remindar = @data_accessor.read(json_data['options']['id'])
      remindar['finish'] = Time.now

      result = {}
      begin
        @data_accessor.create(remindar, json_data['options']['id'])
        result[:status] = 'ok'
        result[:message] = ''
      rescue => e
        result[:status] = 'error'
        result[:message] = e.message
      end
      result
    end
  end
end

