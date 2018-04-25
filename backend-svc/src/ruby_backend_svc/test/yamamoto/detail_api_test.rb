require_relative './base_test'
require_relative '../../src/yamamoto/detail_api'
require 'pry'

module Yamamoto
  class DetailApiTest < BaseTest
    def setup
      super
      create_test_data('1.json', {
          title: 'xxxxxx',
          notify_datetime: '2018-03-20T19:32:01+09:00',
          term: '2018-03-20T19:32:02+09:00',
          memo: 'xxxxxxxxxxxxxxxxxxxxxxx',
          finished_at:  '2018-03-20T19:32:03+09:00',
          created_at:  '2018-03-20T19:32:04+09:00',
      }.to_json)
    end


    def test_detail
      json_data = {'options' => {'id' => 1}}
      result = DetailApi.new.run(json_data)
      assert_equal 1, result['id']
      assert_equal '2018-03-20T19:32:01+09:00', result['notify_datetime']
      assert_equal '2018-03-20T19:32:02+09:00', result['term']
      assert_equal 'xxxxxxxxxxxxxxxxxxxxxxx', result['memo']
      assert_equal '2018-03-20T19:32:03+09:00', result['finished_at']
      assert_equal '2018-03-20T19:32:04+09:00', result['created_at']
    end
  end
end

