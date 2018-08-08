require_relative './base_test'

module Yamamoto
  class ClearApiTest < BaseTest
    def setup
      super
      create_test_data('1.json', '{"title":"xxxxxx","term":"2018-03-20T19:32:00+09:00","finished_at":"2018-03-22T19:32:00+09:00"}')
      create_test_data('2.json', '{"title":"yyyyyy","term":"2018-03-20T19:32:00+09:00"}')
      create_test_data('3.json', '{"title":"zzzzzz","term":"2018-03-21T19:32:00+09:00"}')
      create_test_data('4.json', '{"title":"aaaaaa","term":"2018-03-21T19:32:00+09:00","finished_at":"2018-03-22T19:32:00+09:00"}')
    end

    def test_全件削除できること
      result = ClearApi.new.run(JSON.parse('{"options":{"target":"all"}}'))
      assert_equal 'ok',result[:status]
      assert_equal '',result[:message]
      assert_equal [1, 2, 3, 4], result[:affected_id_list]
    end

    def test_完了したリマインダーのみ削除できること
      result = ClearApi.new.run(JSON.parse('{"options":{"target":"finished"}}'))
      assert_equal 'ok',result[:status]
      assert_equal '',result[:message]
      assert_equal [1, 4], result[:affected_id_list]
    end

    def test_不正なコマンドの場合はエラーになること
      result = ClearApi.new.run(JSON.parse('{"options":{"target":"aaa"}}'))
      assert_equal 'error',result[:status]
      assert result[:message].length > 0
      assert_equal [], result[:affected_id_list]
    end
  end
end

