require_relative './base_api'

module Yoneoka
  class SnoozeApi < BaseApi

    # TODO とりあえずファイルだけ作った

    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)
      id = json_data['options']['id']
      minutes = json_data['options']['minutes']

      current = Time.parse(options['current_time'])
      notify_datetime = current + minutes * 60

      data = {'notify_datetime':notify_datetime}
      @data_accessor.update(data, id)
      {created_at: @data_accessor.read(edit_id)['created_at']}

      data['current_time'] = current
    end

  end
end

# {
#     command: “snooze”,
#     options {
#       id: 1,  // スヌーズ対象のデータID
#       current_time: “2018-03-20T19:32:00+0900”,  // ISO形式
#       minutes: 5  // スヌーズ時間（単位は分）
#   }
# }
#
# ※スヌーズが行われると、現在時刻を起点に minutes で指定された時間後に、
# 無条件に再度通知を発動させなければならない。
# ただし、元データの通知設定時刻は変更してはいけない。
# スヌーズ後の再通知発動前に、元データの通知設定時刻が変更された場合は、
# スヌーズによる再通知をすべて無効とする。
# {
#   status: “ok | error”,
#   message: “xxxxxxxxx”,
#   current_time: “2018-05-31T12:00:00+09:00”,  // システムの現在時刻（ISO形式）＝スヌーズによる再通知の起点時刻
#   next_notify_time: “2018-05-31T12:05:00+09:00”  // 次の通知予定時刻（ISO形式）
# }