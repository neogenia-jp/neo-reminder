require_relative './base_test'

module Kamada
  class ListApiTest < BaseTest
    def setup
      super
      create_test_data('1.json', '{"title":"xxxxxx","term":"2018-03-20T19:32:00+0900"}')
      create_test_data('2.json', '{"title":"yyyyyy","term":"2018-03-20T19:32:00+0900"}')
      create_test_data('3.json', '{"title":"zzzzzz","term":"2018-03-21T19:32:00+0900"}')
    end


    def test_全件取得
      result = ClearApi.new.run(JSON.parse('{"options":{"target":"finished"}}'))
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

