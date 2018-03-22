# テスト対象のモジュールをロード
_dir = File.dirname(__FILE__)
_route = ENV['ROUTE'].downcase
Dir["#{_dir}/../../src/#{_route}/*.rb"].each { |f| p f; require File.expand_path f }

r = _route[0]
_route[0] = r.upcase
MODULE = eval _route

require 'test/unit'
require 'json'
require_relative "./#{ENV['ROUTE'].downcase}/test_data_operator"

class CommonTest < Test::Unit::TestCase
  # テストケースごとに最初に呼ばれるメソッド
  def setup
    ::MODULE::TestDataOperator.create
  end

  # テストケースごとに最後に呼ばれるメソッド
  def teardown
    ::MODULE::TestDataOperator.clean
  end

  # 全TODOリスト取得テスト
  def test_list_api_all
    # TODO: データ作成
    json_data = '{"command":"list","options":{"condition":"all"}}'
    result = ::MODULE::main(json_data)

    result = JSON.parse(result)
    assert_equal 1, result[0][:id]
    assert_equal 'xxxxxx', result[0][:title]
    assert_equal '2018-03-20T19:32:00+0900', result[0][:term]
    assert_equal 2, result[1][:id]
    assert_equal 'yyyyyy', result[1][:title]
    assert_equal '2018-03-20T19:33:00+0900', result[1][:term]
  end

  # 本日のTODOリスト取得テスト
  def test_list_api_today
    # TODO: データ作成
    json_data = '{"command":"list","options":{"condition":"today"}}'
    result = ::MODULE::main(json_data)

    result = JSON.parse(result)
    assert_equal 2, result.length
    assert_equal 1, result[0][:id]
    assert_equal 'xxxxxx', result[0][:title]
    assert_equal '2018-03-20T19:32:00+0900', result[0][:term]
    assert_equal 2, result[1][:id]
    assert_equal 'yyyyyy', result[1][:title]
    assert_equal '2018-03-20T19:33:00+0900', result[1][:term]
  end

  # 登録テスト
  def test_create_api
    json_data = '{"command":"create","options":{"title":“xxxxx”}}'
    result = ::MODULE::main(json_data)

    result = JSON.parse(result)
    assert_equal 'ok', result[:status]
    assert_equal '', result[:message]
  end

  # 登録エラーテスト
  def test_create_api_error
    json_data = '{"command":"create","options":{"title":“xxxxx”}}'
    result = ::MODULE::main(json_data)

    result = JSON.parse(result)
    assert_equal 'error', result[:status]
    assert_equal 'Create Failed...', result[:message]
  end

  # 詳細テスト
  def test_detail_api
    json_data = '{"command":“detail”,"options":{"id":1}}'
    result = ::MODULE::main(json_data)

    result = JSON.parse(result)
    assert_equal 1, result[:id]
    assert_equal 'xxxxxx', result[:title]
    assert_equal '2018-03-20T19:32:00+0900', result[:notify_datetime]
    assert_equal '2018-03-20T19:32:00+0900', result[:term]
    assert_equal 'xxxxxxxxxxxxxxxxxxxxxxx', result[:memo]
    assert_equal '2018-03-20T19:32:00+0900', result[:finished_at]
    assert_equal '2018-03-20T19:32:00+0900', result[:created_at]
  end

  # 編集テスト
  def test_edit_api
    json_data = '{"command":“edit”,"options":{"id":1,"title":“xxxxxx”,"notify_datetime":“2018-03-20T19:32:00+0900”,"term":“2018-03-20T19:32:00+0900”,"memo":“xxxxxxxxxxxxxxxxxxxxxxx”}'
    result = ::MODULE::main(json_data)

    result = JSON.parse(result)
    assert_equal 'ok', result[:status]
    assert_equal '', result[:message]
    assert_equal '2018-03-20T19:32:00+0900', result[:created_at]
  end

  # 編集エラーテスト
  def test_edit_api_error
    json_data = '{"command":“edit”,"options":{"id":1,"title":“xxxxxx”,"notify_datetime":“2018-03-20T19:32:00+0900”,"term":“2018-03-20T19:32:00+0900”,"memo":“xxxxxxxxxxxxxxxxxxxxxxx”}'
    result = ::MODULE::main(json_data)

    result = JSON.parse(result)
    assert_equal 'error', result[:status]
    assert_equal 'Edit Failed...', result[:message]
    assert_equal '', result[:created_at]
  end

  # 完了テスト
  def test_finish_api
    json_data = '{"command":“finish”,"options":{"id":1}}'
    result = ::MODULE::main(json_data)

    result = JSON.parse(result)
    assert_equal 'ok', result[:status]
    assert_equal '', result[:message]
    assert_equal '2018-03-20T19:32:00+0900', result[:finished_at]
  end

  # 完了エラーテスト
  def test_finish_api_error
    json_data = '{"command":“finish”,"options":{"id":1}}'
    result = ::MODULE::main(json_data)

    result = JSON.parse(result)
    assert_equal 'error', result[:status]
    assert_equal 'Edit Failed...', result[:message]
    assert_equal '', result[:finished_at]
  end

  # 削除テスト
  def test_finish_api
    json_data = '{"command":"delete","options":{"id":1}}'
    result = ::MODULE::main(json_data)

    result = JSON.parse(result)
    assert_equal 'ok', result[:status]
    assert_equal '', result[:message]
  end

  # 削除エラーテスト
  def test_finish_api
    json_data = '{"command":"delete","options":{"id":1}}'
    result = ::MODULE::main(json_data)

    result = JSON.parse(result)
    assert_equal 'error', result[:status]
    assert_equal 'Delete Failed...', result[:message]
  end
end

