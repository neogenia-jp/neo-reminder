require_relative './base_test'

module Yamamoto
  class DataAccessorTest < BaseTest
    def setup
      # ファイル作成
      super
      create_test_data('1.json', '{"title":"xxxxxx","term":"2018-03-20T19:32:00+09:00"}')
      create_test_data('2.json', '{"title":"yyyyyy","term":"2018-03-20T19:30:00+09:00"}')
    end

    def teardown
      super
    end

    def test_read
      data = @data_accessor.read(1)
      assert_equal 1, data['id']
      assert_equal 'xxxxxx', data['title']
      assert_equal '2018-03-20T19:32:00+09:00', data['term']
    end

    def test_all_read
      data = @data_accessor.all_read
      assert_equal 2, data.length
      assert_equal 1, data[0]['id']
      assert_equal 'xxxxxx', data[0]['title']
      assert_equal '2018-03-20T19:32:00+09:00', data[0]['term']
      assert_equal 2, data[1]['id']
      assert_equal 'yyyyyy', data[1]['title']
      assert_equal '2018-03-20T19:30:00+09:00', data[1]['term']
    end

    def test_create
      data = @data_accessor.create({'title' => 'zzzzzz','term' => '2018-03-20T20:32:00+09:00'})
      assert_equal 3, data['id']
      assert_equal 'zzzzzz', data['title']
      assert_equal '2018-03-20T20:32:00+09:00', data['term']
      assert data['created_at'].length > 0

      # 実際のファイルの中身も確認
      data = JSON.parse(File.read(File.join(@data_path, '3.json')))
      assert_equal 'zzzzzz', data['title']
      assert_equal '2018-03-20T20:32:00+09:00', data['term']
      assert data['created_at'].length > 0
    end

    def test_update
      data = @data_accessor.update({'title' => 'zzzzzz', 'aaa' => 'bbb'}, 1)
      assert_equal 1, data['id']
      assert_equal 'zzzzzz', data['title']
      assert_equal '2018-03-20T19:32:00+09:00', data['term']
      assert_equal 'bbb', data['aaa']
      assert data['updated_at'].length > 0

      # 実際のファイルの中身も確認
      data = JSON.parse(File.read(File.join(@data_path, '1.json')))
      assert_equal 'zzzzzz', data['title']
      assert_equal '2018-03-20T19:32:00+09:00', data['term']
      assert_equal 'bbb', data['aaa']
      assert data['updated_at'].length > 0
    end

    def test_delete
      @data_accessor.delete(1)
      refute File.exist?(File.join(@data_path, '1.json'))
    end

    def test_next_id
      data = @data_accessor.next_id
      assert_equal 3, data
    end

    def test_id_list
      data = @data_accessor.id_list
      assert_equal 2, data.length
      assert_equal 1, data[0]
      assert_equal 2, data[1]
    end

  end
end
