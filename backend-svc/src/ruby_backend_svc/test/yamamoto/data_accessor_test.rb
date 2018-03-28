require 'test/unit'
require_relative '../../src/yamamoto/data_accessor'

class DataAccessorTest < Test::Unit::TestCase
  def setup
    # ファイル作成
    File.write(File.expand_path("./data/1.json"), '{"title":"xxxxxx","term":"2018-03-20T19:32:00+0900"}')
    File.write(File.expand_path("./data/2.json"), '{"title":"yyyyyy","term":"2018-03-20T19:32:00+0900"}')
  end

  def teardown
    # ファイル削除
    file_names = Dir.glob(File.join(File.expand_path("./data"), "*"))
    file_names.each do |name|
      File.delete(name)
    end
  end

  def test_read
    data_accessor = Yamamoto::DataAccessor.new
    data = data_accessor.read(1)
    assert_equal '{"title":"xxxxxx","term":"2018-03-20T19:32:00+0900"}', data
  end

  def test_all_read
    data_accessor = Yamamoto::DataAccessor.new
    data = data_accessor.all_read
    assert_equal 2, data.length
    assert_equal '{"title":"xxxxxx","term":"2018-03-20T19:32:00+0900"}', data[0]
    assert_equal '{"title":"yyyyyy","term":"2018-03-20T19:32:00+0900"}', data[1]
  end

  def test_create
    data_accessor = Yamamoto::DataAccessor.new
    data = data_accessor.create('{"title":"zzzzzz","term":"2018-03-20T19:32:00+0900"}')
    assert data > 0
    assert File.exist?(File.expand_path("./data/3.json"))
    assert_equal '{"title":"zzzzzz","term":"2018-03-20T19:32:00+0900"}', File.read(File.expand_path("./data/3.json"))
  end

  def test_next_id
    data_accessor = Yamamoto::DataAccessor.new
    data = data_accessor.next_id
    assert_equal 3, data
  end

  def test_id_list
    data_accessor = Yamamoto::DataAccessor.new
    data = data_accessor.id_list
    assert_equal 2, data.length
    assert_equal 1, data[0]
    assert_equal 2, data[1]
  end
end

