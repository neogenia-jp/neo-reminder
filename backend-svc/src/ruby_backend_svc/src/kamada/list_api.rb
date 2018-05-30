require 'date'
require_relative './base_api'

module Kamada
  class ListApi < BaseApi

    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)

      case json_data['options']
      when 'all'
        list = reminder_list_all
      when 'today'
        list = reminder_list_today
      when 'unfinished'
        list = reminder_list_unfinished

      # 完了しているかどうかのフラグを付与する
      list.each do |r|
        r['finished'] = r['finished_at'].nil? ? false : true
      end

      # JSON形式にフォーマットし文字列で返す
      { list: list }
    end

    private

    # リマインダーを取得する（全て）
    # @return [Array]
    def reminder_list_all
      @data_accessor.all_read
    end

    # リマインダーを取得する（本日）
    # @return [Array]
    def reminder_list_today
      day = Date.today
      data = @data_accessor.all_read
      data.select {|d| Date.parse(d['notify_datetime']) == day}
    end

    # リマインダーを取得する（未完了のみ）
    # @return [Array]
    def reminder_list
      data = @data_accessor.all_read
      data.select {|d| d['finished_at'].nil?}
    end
  end
end
