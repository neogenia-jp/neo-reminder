require_relative './base_test'
require_relative '../../src/yamamoto/create_api'

module Yamamoto
  class CreateApiTest < BaseTest
    def setup
      super
    end

    def test_1件作成できること
      result = CreateApi.new.run(JSON.parse('{"options":{"title":"xxxxx"}}'))
      assert_equal 'ok',result[:status]
      assert_equal '',result[:message]
      #assert result[:created_at].length > 0

      # 実際のファイルの中身も確認
      data = JSON.parse(File.read(File.join(@data_path, '1.json')))
      assert_equal 'xxxxx', data['title']
      assert data['created_at'].length > 0
    end
  end
end

