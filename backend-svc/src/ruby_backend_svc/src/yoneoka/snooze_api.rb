require_relative './base_api'

module Yoneoka
  class SnoozeApi < BaseApi

    # 実行
    # @param json_data [Hash] 送られてきたJSONデータ
    # @return [Hash]
    def run(json_data)
      id = json_data['options']['id']
      minutes = json_data['options']['minutes'].to_i

      current_datetime = Time.parse(options['current_time'])
      next_notify_datetime = current_datetime + minutes * 60

      data = {'next_notify_datetime':next_notify_datetime}
      @data_accessor.update(data, id)
      {created_at: @data_accessor.read(edit_id)['created_at']}

      data['current_time'] = current_datetime
      data #returnするのにもう一度書くのがなんかダサい…
    end

  end
end