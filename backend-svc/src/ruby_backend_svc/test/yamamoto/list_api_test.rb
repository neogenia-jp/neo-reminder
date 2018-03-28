require_relative './base_test'

module Yamamoto
  class ListApiTest < BaseTest
    def setup
      super
      create_test_data('1.json', '{"title":"xxxxxx","term":"2018-03-20T19:32:00+0900"}')
      create_test_data('2.json', '{"title":"yyyyyy","term":"2018-03-20T19:32:00+0900"}')
      create_test_data('3.json', '{"title":"zzzzzz","term":"2018-03-21T19:32:00+0900"}')
    end


    def test_全件取得
      result = ListApi.new.run(JSON.parse('{"options":{"condition":"all"}}'))
      assert_equal result[:list][0], { 'title' => 'xxxxxx', 'term' => '2018-03-20T19:32:00+0900', 'id' => 1 }
      assert_equal result[:list][1], { 'title' => 'yyyyyy', 'term' => '2018-03-20T19:32:00+0900', 'id' => 2 }
      assert_equal result[:list][2], { 'title' => 'zzzzzz', 'term' => '2018-03-21T19:32:00+0900', 'id' => 3 }
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
  end
end

