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
        # スヌーズによるターゲットか
        is_target1 = is_notify_target(data, json_data['options'])
        @data_accessor.update({'next_notified_at': json_data['options']['current_time']}, data['id']) if is_target1

        # 期限によるターゲットか
        is_target2 = is_term_target(data, json_data['options'])
        @data_accessor.update({'term_notified_at': json_data['options']['current_time']}, data['id']) if is_target2

        # 通常の通知によるターゲットか
        is_target3 = is_notify_target(data, json_data['options'])
        @data_accessor.update({'notified_at': json_data['options']['current_time']}, data['id']) if is_target3

        # いずれかで通知対象なら配列に追加する
        notifications.push({subject: data['title'], body: data['memo']}) if (is_target1 || is_target2 || is_target3)
      end
      {notifications: notifications}
    end

    # private

    # スヌーズによるターゲットチェック
    def is_notify_target_sn(data, options)
      return false if (data.has_key?('finished_at')) # 完了なら対象外
      return false if (data.has_key?('next_notified_at')) # スヌーズ通知済みなら対象外

      # スヌーズ通知時刻によるチェック
      return false if (!data.has_key?('next_notify_datetime')) # スヌーズ通知時刻がないなら対象外
      current = Time.parse(options['current_time'])
      next_notify_datetime = Time.parse(data['next_notify_datetime'])
      return (current > next_notify_datetime)
    end

    # 期限によるターゲットチェック
    def is_term_target(data, options)
      return false if (data.has_key?('finished_at')) # 完了なら対象外
      return false if (data.has_key?('term_notified_at')) # 期限通知済みなら対象外

      # 期限時刻によるチェック
      return false if (!data.has_key?('term')) # 期限時刻がないなら対象外
      current = Time.parse(options['current_time'])
      term = Time.parse(data['term'])
      return (current > term)
    end

    # 通常の通知によるターゲットチェック
    def is_notify_target(data, options)
      return false if (data.has_key?('finished_at')) # 完了なら対象外
      return false if (data.has_key?('notified_at')) # 通知済みなら対象外

      # 通知時刻によるチェック
      return false if (!data.has_key?('notify_datetime')) # 通知時刻がないなら対象外(＝詳細編集がまだ)
      current = Time.parse(options['current_time'])
      notify_datetime = Time.parse(data['notify_datetime'])
      return false if current < notify_datetime

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
      is_outside = distance > data['radius'].to_i
      if (data['direction'] == 'in')
        !is_outside
      else
        is_outside
      end
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
