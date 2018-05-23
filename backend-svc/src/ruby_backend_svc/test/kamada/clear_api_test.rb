require_relative './base_test'

module Kamada
  class ListApiTest < BaseTest
    def setup
      super
      create_test_data('1.json', '{"title":"xxxxxx", "term":"2018-03-20T19:32:00+0900"}')
      create_test_data('2.json', '{"title":"yyyyyy", "term":"2018-03-20T19:32:00+0900"}')
      create_test_data('3.json', '{"title":"zzzzzz", "term":"2018-03-21T19:32:00+0900", "finished_at":"2018-03-20T19:32:00+0900"}')
    end

    def test_全削除
      result = ClearApi.new.run(JSON.parse('{"options":{"target":"all"}}'))
      assert_equal 3, result[:affected_id_list].count
      assert_equal 1, result[:affected_id_list][0]
      assert_equal 2, result[:affected_id_list][1]
      assert_equal 3, result[:affected_id_list][2]
    end

    def test_完了済みリマインダーのみ削除
      result = ClearApi.new.run(JSON.parse('{"options":{"target":"finished"}}'))
      assert_equal 1, result[:affected_id_list].count
      assert_equal 3, result[:affected_id_list][0]
    end
  end
end
