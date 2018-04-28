require 'date'
require_relative './base_api'

module Yamamoto
  class ListApi < BaseApi

    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)

      # リマインダーを取得する
      day = json_data['options'] == 'today' ? Date.today : nil

      # JSON形式にフォーマットし文字列で返す
      { list: reminder_list(day) }
    end

    private

    # リマインダーを取得する
    # @param day [Date] 日付
    # @return [String]
    def reminder_list(day)
      data = @data_accessor.all_read
      return data if day.nil?
      data.select {|d| Date.parse(d['notify_datetime']) == day}
    end
  end
end

