require 'time'
require_relative './base_api'

module Yoneoka
  class ObserveApi < BaseApi
    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)

      notifications = []
      @data_accessor.all_read.each do |item|
        next unless (is_notify_target(item, json_data['options']))
        notifications.push({subject: item['title'], body: item['memo']})
      end
      {notifications: notifications}

    end

    private
    def is_notify_target(item, options)
      # finished_at 完了なら通知しない
      return false if (!item['finished_at'].nil?)

      # notify_datetime 現在時刻からxx秒以内が通知対象(とりあえず60秒)
      current = Time.parse(options['current_time'])
      notify_datetime = Time.parse(item['notify_datetime'])
      return false if (current > notify_datetime) # 通知時間が過ぎているものは対象外
      return false if (notify_datetime - current > 60)

      # lat long （今後の拡張用）

      return true
    end
  end
end
