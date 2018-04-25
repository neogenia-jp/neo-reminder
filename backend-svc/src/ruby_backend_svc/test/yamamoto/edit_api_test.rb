require_relative './base_test'
require_relative '../../src/yamamoto/edit_api'

module Yamamoto
  class EditApiTest < BaseTest
    def setup
      super
      create_test_data('1.json', {
          title: 'xxxxxx',
          notify_datetime: '2018-03-20T19:32:01+09:00',
          term: '2018-03-20T19:32:02+09:00',
          memo: 'xxxxxxxxxxxxxxxxxxxxxxx',
          created_at:  '2018-03-20T19:32:04+09:00',
      }.to_json)
    end


    def test_edit
      # 編集前の内容を確認
      data = JSON.parse(File.read(File.join(@data_path, '1.json')))
      assert_equal 'xxxxxx', data['title']
      assert_equal '2018-03-20T19:32:01+09:00', data['notify_datetime']
      assert_equal '2018-03-20T19:32:02+09:00', data['term']
      assert_equal 'xxxxxxxxxxxxxxxxxxxxxxx', data['memo']
      assert_equal '2018-03-20T19:32:04+09:00', data['created_at']

      json_data = {
          'options' => {
              'id' => 1,
              'title' => 'yyyyyy',
              'notify_datetime' => '2018-03-21T19:32:00+09:00',
              'memo' => 'aaa',
          }
      }
      result = EditApi.new.run(json_data)

      data = JSON.parse(File.read(File.join(@data_path, '1.json')))
      assert_equal 'yyyyyy', data['title']
      assert_equal '2018-03-21T19:32:00+09:00', data['notify_datetime']
      assert_equal '2018-03-20T19:32:02+09:00', data['term']
      assert_equal 'aaa', data['memo']
      assert_equal '2018-03-20T19:32:04+09:00', data['created_at']
      assert data['updated_at'].length > 0
    end
  end
end

