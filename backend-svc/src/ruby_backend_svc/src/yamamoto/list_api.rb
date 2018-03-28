module Yamamoto
  class ListApi < BaseApi

    # 実行
    # @param json_data [JSON] 送られてきたJSONデータ
    # @return [String]
    def run(json_data)

      # リマインダーを取得する
      if json_data[:options] == 'today'
        day = Date.today
      else
        day = nil
      end
      list = reminder_list(day)

      # JSON形式にフォーマットし文字列で返す
      list.to_json.to_s
    end

    private

    # リマインダーを取得する
    # @param day [Date] 日付
    # @return [String]
    def reminder_list(day=nil)
      reminders = @data_accessor.all_read
      if day
        # その日のリマインダーだけ取得
      end
    end
  end
end

