require 'time'
require_relative './base_api'

module Yoneoka
  class ClearApi < BaseApi

    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)

      target = json_data['options']['target']
      result = {}

      begin
        affected_id_list = []
        @data_accessor.all_read.each do |item|
          next if (target == 'finished' && item['finished_at'].nil?)
          @data_accessor.delete(item['id'])
          affected_id_list.push(item['id'])
        end
        result[:status] = 'ok'
        result[:message] = ''
        result[:affected_id_list] = affected_id_list
      rescue => e
        result[:status] = 'error'
        result[:message] = e.message
      end
      result

    end
  end
end
