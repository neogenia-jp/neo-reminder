require 'date'
require_relative './base_api'

module Yamamoto
  class ListApi < BaseApi

    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)

      # リマインダーを取得する
      result = nil
      case json_data['options']['condition']
        when 'today'
          result = today_reminder_list(Date.today)
        when 'all'
          result = reminder_list
        when 'unfinished'
          result = unfinished_reminder_list
      end

      result = add_finished_key(result)
      { list: result }
    end

    private

    # リマインダーを取得する
    # @return [Array]
    def reminder_list
      @data_accessor.all_read
    end

    # 指定された日付のリマインダーを取得する
    # @param day [Date] 日付
    # @return [Array]
    def today_reminder_list(day)
      data = reminder_list
      data.select {|d| Date.parse(d['notify_datetime']) == day}
    end

    # 完了していないリマインダーを取得する
    # @return [Array]
    def unfinished_reminder_list
      data = reminder_list
      data.select {|d| d['finished_at'].nil? }
    end

    # 完了かどうかのキーを追加する
    # @param reminders [Array]
    # @return [Array]
    def add_finished_key(reminders)
      reminders.each do |r|
        if r['finished_at'].nil?
          r['finished'] = false
        else
          r['finished'] = true
        end
      end
    end
  end
end

