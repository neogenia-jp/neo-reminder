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

    def distance(lat1, lng1, lat2, lng2)
      # cf. http://techblog.kyamanak.com/entry/2017/07/09/164052
      # ラジアン単位に変換
      x1 = lat1.to_f * Math::PI / 180
      y1 = lng1.to_f * Math::PI / 180
      x2 = lat2.to_f * Math::PI / 180
      y2 = lng2.to_f * Math::PI / 180

      # 地球の半径 (m)
      radius = 6378137

      # 差の絶対値
      diff_y = (y1 - y2).abs

      calc1 = Math.cos(x2) * Math.sin(diff_y)
      calc2 = Math.cos(x1) * Math.sin(x2) - Math.sin(x1) * Math.cos(x2) * Math.cos(diff_y)

      # 分子
      numerator = Math.sqrt(calc1 ** 2 + calc2 ** 2)

      # 分母
      denominator = Math.sin(x1) * Math.sin(x2) + Math.cos(x1) * Math.cos(x2) * Math.cos(diff_y)

      # 弧度
      degree = Math.atan2(numerator, denominator)

      # 大円距離 (km)
      degree * radius
    end
  end
end
