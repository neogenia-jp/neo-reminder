require 'test/unit'
require 'json'

class TestV1 < Test::Unit::TestCase

  def _exec_command(input_data)
    `ROUTE=#{ENV['ROUTE']} bash /mnt/route.sh 2>/tmp/stderr <<__XXX__\n#{input_data}`
  end

  def _call_svc(json)
    if json.is_a? Hash
      json = json.to_json
    end

    begin
      result = _exec_command json
    rescue => e
      if result
        stdout = "\n----- STDOUT -----\n#{result}"
      end
      if File.exist? '/tmp/stderr'
        stderr = "\n----- STDERR -----\n" + File.read('/tmp/stderr')
      end

      raise "Service error.#{e}#{stdout}#{stderr}"
    end

    assert_not_equal '', result, 'No response of service!!!'

    JSON.parse(result, symbolize_names: true)
  end

  def test_scenario
    # 1件登録する
    json_data = '{"command":"create","options":{"title":"テスト"}}'
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]

    # 取得してみる
    json_data = '{"command":"list","options":{"condition":"all"}}'
    result = _call_svc(json_data)

    assert_equal 1, result[:list].length
    assert_equal 'テスト', result[:list][0][:title]
    assert result[:list][0][:term] == nil || result[:list][0][:term] == ''

    # もう1件登録する
    json_data = '{"command":"create","options":{"title":"打ち上げに行く"}}'
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]

    # 取得してみる
    json_data = '{"command":"list","options":{"condition":"all"}}'
    result = _call_svc(json_data)

    assert_equal 2, result[:list].length
    assert_equal 'テスト', result[:list][0][:title]
    assert result[:list][0][:term] == nil || result[:list][0][:term] == ''
    assert_equal '打ち上げに行く', result[:list][1][:title]
    assert result[:list][1][:term] == nil || result[:list][1][:term] == ''

    entity_id = result[:list][0][:id]

    # 編集
    json_data = {
      command: :edit,
      options: {
        id:              entity_id,
        title:           'テストコードを書く',
        notify_datetime: '2018-03-20T17:00:00+09:00',
        term:            '2018-03-21T10:30:00+09:00',
        memo:            '実装した新機能のテストコードがまだないので書く'
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert is_iso_date(result[:created_at])

    # 一覧取得
    json_data = '{"command":"list","options":{"condition":"all"}}'
    result = _call_svc(json_data)

    assert_equal 2, result[:list].length
    assert_equal entity_id, result[:list][0][:id]  # IDは変わってないこと
    assert_equal 'テストコードを書く', result[:list][0][:title]
    assert_equal '2018-03-21T10:30:00+09:00', result[:list][0][:term]
    assert_equal '打ち上げに行く', result[:list][1][:title]
    assert result[:list][1][:term] == nil || result[:list][1][:term] == ''

    # 詳細
    json_data = {
      command: :detail,
      options: {
        id: entity_id
      }
    }

    result = _call_svc(json_data)

    assert_equal entity_id, result[:id]  # IDは変わってないこと
    assert_equal 'テストコードを書く', result[:title]
    assert_equal '2018-03-20T17:00:00+09:00', result[:notify_datetime]
    assert_equal '2018-03-21T10:30:00+09:00', result[:term]
    assert_equal '実装した新機能のテストコードがまだないので書く', result[:memo]
    assert result[:finished_at] == nil || result[:finished_at] == ''
    assert is_iso_date(result[:created_at])
    entity1_created_at = result[:created_at]

    # 完了
    json_data = %Q/{"command":"finish","options":{"id":#{entity_id}}}/
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert is_iso_date(result[:finished_at])

    # 詳細
    json_data = {
      command: :detail,
      options: {
        id: entity_id
      }
    }

    result = _call_svc(json_data)

    assert_equal entity_id, result[:id]  # IDは変わってないこと
    assert_equal 'テストコードを書く', result[:title]
    assert_equal '2018-03-20T17:00:00+09:00', result[:notify_datetime]
    assert_equal '2018-03-21T10:30:00+09:00', result[:term]
    assert_equal '実装した新機能のテストコードがまだないので書く', result[:memo]
    assert is_iso_date(result[:finished_at])
    assert_equal entity1_created_at, result[:created_at]

    # 削除
    json_data = %Q/{"command":"delete","options":{"id":#{entity_id}}}/
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]

    # 一覧取得
    json_data = '{"command":"list","options":{"condition":"all"}}'
    result = _call_svc(json_data)

    assert_equal 1, result[:list].length
    assert_equal '打ち上げに行く', result[:list][0][:title]
    entity_id = result[:list][0][:id]

    # 削除
    json_data = %Q/{"command":"delete","options":{"id":#{entity_id}}}/
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]

    # 取得
    json_data = '{"command":"list","options":{"condition":"all"}}'
    result = _call_svc(json_data)

    assert_equal 0, result[:list].length
  end

  def is_iso_date(iso_date)
    iso_date =~ /\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\+\d\d:\d\d/
  end
end

