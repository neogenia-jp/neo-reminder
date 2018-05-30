require_relative './base_test'

module Kamada
  class ObserveApiTest < BaseTest
    def setup
      super
      create_test_data('1.json', '{"title":"xxxxxx", "memo":"メモ１"}')
      create_test_data('2.json', '{"title":"yyyyyy", "memo":"メモ２"}')
      create_test_data('3.json', '{"title":"zzzzzz", "memo":"メモ３"}')
    end

    def test_observe
      result = ObserveApi.new.run(JSON.parse('{"options":{"current_time":"2018-03-20T19:32:00+0900", "lat":0.0, "long":0.0}}'))
      assert_equal 3, result[:notifications].count
      assert_equal "「xxxxxx」の通知", result[:notifications][0][:subject]
      assert_equal "「yyyyyy」の通知", result[:notifications][1][:subject]
      assert_equal "「zzzzzz」の通知", result[:notifications][2][:subject]
      assert_equal "メモ１", result[:notifications][0][:body]
      assert_equal "メモ２", result[:notifications][1][:body]
      assert_equal "メモ３", result[:notifications][2][:body]
    end
  end
end
