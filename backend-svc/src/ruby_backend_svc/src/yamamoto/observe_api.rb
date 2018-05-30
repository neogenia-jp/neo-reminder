require_relative './base_api'
require 'time'

module Yamamoto
  class ObserveApi < BaseApi

    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)
      options = json_data['options']

      # 通知するリマインダーを取得
      remindars = @data_accessor.all_read.select do |data|
        !data['notify_datetime'].nil? &&
            (Time.parse(data['notify_datetime']) <= Time.parse(options['current_time'])) &&
            data['notified'] != 1
      end

      # データ整形
      notifications = remindars.inject([]) do |memo, d|
        memo << {
            subject: d['title'],
            body: d['memo'],
            svc_data: {}
        }; memo
      end

      # 通知済みに設定する
      remindars.each do |data|
        @data_accessor.update({notified: 1}, data['id'])
      end

      {
          status: 'ok',
          message: '',
          notifications: notifications
      }
    rescue => e
      {
          status: 'error',
          message: "#{e.message}\n#{e.backtrace}",
          notifications: []
      }
    end
  end
end

