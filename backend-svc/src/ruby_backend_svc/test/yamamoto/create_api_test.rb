require_relative './base_test'

module Yamamoto
  class CreateApiTest < BaseTest
    def setup
      super
    end

    def test_1件作成できること
      result = CreateApi.new.run(JSON.parse('{"options":{"title":"xxxxx"}}'))
      assert_equal result, {
          status: "ok",
          message: ""
      }

      # ファイルが作成されていてかつ中身が正しいことを確認
      assert_equal '{"title":"xxxxx"}', File.read(File.join(@data_path, '1.json'))
    end
  end
end

