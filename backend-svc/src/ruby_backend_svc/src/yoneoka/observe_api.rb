require 'time'
require_relative './base_api'

module Yoneoka
  class ObserveApi < BaseApi
    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)

      notifications = []
      @data_accessor.all_read.each do |data|
        next unless (is_notify_target(data, json_data['options']))
        @data_accessor.update({'notify':""}, data['id'])
        notifications.push({subject: data['title'], body: data['memo']})
      end
      {notifications: notifications}
    end

    private

    def is_notify_target(data, options)
      # finished_at 完了なら通知しない
      return false if (data.has_key?('finished_at'))
      # 通知時間未設定(＝詳細編集がまだ)なら通知しない
      return false if (!data.has_key?('notify_datetime'))

      # 通知時間によるチェック
      current = Time.parse(options['current_time'])
      notify_datetime = Time.parse(data['notify_datetime']) # 本来の通知時間
      if (data.has_key?('next_notify_datetime'))
        # スヌーズあり
        next_notify_datetime = Time.parse(data['next_notify_datetime']) # スヌーズの再通知時間
        return false if !is_target_by_time(current, next_notify_datetime)
      else
        # スヌーズなし
        return false if !is_target_by_time(current, notify_datetime)
      end

      # 位置情報によるチェック
      # 位置情報チェックをするか否か
      is_geo = options.has_key?('lat') && options.has_key?('long') &&
          data.has_key?('lat') && data.has_key?('long') &&
          data.has_key?('direction') && data.has_key?('radius')
      if (!is_geo)
        # 位置情報チェックをしないならtrue
        return true
      end
      distance = calc_distance(options['lat'], options['long'], data['lat'], data['long'])
      is_inside = distance > data['radius'].to_i
      if (data['direction'] == 'in')
        is_inside
      else
        !is_inside
      end
    end

    def is_target_by_time(current_datetime, notify_datetime)
      return false if (current_datetime < notify_datetime) # 通知時間前なら対象外
      return false if (current_datetime - notify_datetime > 60)
      # 現在時刻から60秒以内
      true
    end

    def calc_distance(lat1, lng1, lat2, lng2)
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
