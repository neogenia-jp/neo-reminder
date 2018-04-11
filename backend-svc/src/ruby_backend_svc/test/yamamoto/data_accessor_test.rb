require_relative './base_test'

module Yamamoto
  class DataAccessorTest < BaseTest
    def setup
      # ファイル作成
      super
      create_test_data('1.json', '{"title":"xxxxxx","term":"2018-03-20T19:32:00+0900"}')
      create_test_data('2.json', '{"title":"yyyyyy","term":"2018-03-20T19:32:00+0900"}')
    end

    def teardown
      super
    end

    def test_read
      data = @data_accessor.read(1)
      assert_equal({'title' => 'xxxxxx', 'term' => '2018-03-20T19:32:00+0900', 'id' => 1}, data)
    end

    def test_all_read
      data = @data_accessor.all_read
      assert_equal 2, data.length
      assert_equal({'title' => 'xxxxxx', 'term' => '2018-03-20T19:32:00+0900', 'id' => 1}, data[0])
      assert_equal({'title' => 'yyyyyy', 'term' => '2018-03-20T19:32:00+0900', 'id' => 2}, data[1])
    end

    def test_create
      data = @data_accessor.create({'title' => 'zzzzzz','term' => '2018-03-20T19:32:00+0900'})
      assert data > 0
      assert File.exist?(File.join(@data_path, '3.json'))
      assert_equal '{"title":"zzzzzz","term":"2018-03-20T19:32:00+0900"}', File.read(File.join(@data_path, '3.json'))
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
