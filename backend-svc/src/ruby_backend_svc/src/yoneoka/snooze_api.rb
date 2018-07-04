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