require_relative './base_api'

module Yamamoto
  class ClearApi < BaseApi

    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)
      options = json_data['options']
      case options['target']
        when 'all'
          clear_all
        when 'finished'
          clear_finished
        else
          {
            status: 'error',
            message: "targetに不正な文字列が指定されました。target[#{options['target']}]",
            affected_id_list: []
          }
      end
    end

    def clear_all
      affected_id_list = []
      @data_accessor.all_read.each do |data|
        @data_accessor.delete(data['id'])
        affected_id_list << data['id']
      end

      {
          status: 'ok',
          message: '',
          affected_id_list: affected_id_list
      }
    end

    def clear_finished
      affected_id_list = []
      @data_accessor.all_read.select { |data| !data['finished_at'].nil? }.each do |data|
        @data_accessor.delete(data['id'])
        affected_id_list << data['id']
      end

      {
          status: 'ok',
          message: '',
          affected_id_list: affected_id_list
      }
    end
  end
end

