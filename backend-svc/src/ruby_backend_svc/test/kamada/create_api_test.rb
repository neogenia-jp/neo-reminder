require_relative './base_test'

module Yamamoto
  class CreateApiTest < BaseTest
    def setup
      super
    end

    def test_1件作成できること
      result = CreateApi.new.run(JSON.parse('{"options":{"title":"xxxxx"}}'))
      assert_equal 'ok',result[:status]
      assert_equal '',result[:message]
      assert result[:created_at].length > 0
    end
  end
end
