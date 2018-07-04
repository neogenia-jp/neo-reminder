require_relative './base_test'
require 'pry'

module Yamamoto
  class ListApiTest < BaseTest
    def setup
      super
      create_test_data('1.json', '{"title":"xxxxxx","term":"2018-03-20T19:32:00+09:00","finished_at":"2018-03-22T19:32:00+09:00"}')
      create_test_data('2.json', '{"title":"yyyyyy","term":"2018-03-20T19:32:00+09:00"}')
      create_test_data('3.json', '{"title":"zzzzzz","term":"2018-03-21T19:32:00+09:00"}')
    end


    def test_all
      json_data = {'options' => {'condition' => 'all'}}
      result = ListApi.new.run(json_data)
      assert_equal 1, result[:list][0]['id']
      assert_equal 'xxxxxx', result[:list][0]['title']
      assert_equal '2018-03-20T19:32:00+09:00', result[:list][0]['term']
      assert_equal true, result[:list][0]['finished']
      assert_equal 2, result[:list][1]['id']
      assert_equal 'yyyyyy', result[:list][1]['title']
      assert_equal '2018-03-20T19:32:00+09:00', result[:list][1]['term']
      assert_equal false, result[:list][1]['finished']
      assert_equal 3, result[:list][2]['id']
      assert_equal 'zzzzzz', result[:list][2]['title']
      assert_equal '2018-03-21T19:32:00+09:00', result[:list][2]['term']
      assert_equal false, result[:list][2]['finished']
    end

    def test_本日のみ取得
      # TODO: Timecop的なのほしい
      #ListApi.new.run(JSON.parse('{"options":{"condition":"today"}}'))
      #assert_equal result, {
      #    list: [
      #        { id: 3, title: "zzzzzz", term: "2018-03-21T19:32:00+0900" },
      #    ]
      #}.to_json
    end

    def test_unfinished
      json_data = {'options' => {'condition' => 'unfinished'}}
      result = ListApi.new.run(json_data)
      assert_equal 2, result[:list][0]['id']
      assert_equal 'yyyyyy', result[:list][0]['title']
      assert_equal '2018-03-20T19:32:00+09:00', result[:list][0]['term']
      assert_equal false, result[:list][0]['finished']
      assert_equal 3, result[:list][1]['id']
      assert_equal 'zzzzzz', result[:list][1]['title']
      assert_equal '2018-03-21T19:32:00+09:00', result[:list][1]['term']
      assert_equal false, result[:list][1]['finished']
    end
  end
end
