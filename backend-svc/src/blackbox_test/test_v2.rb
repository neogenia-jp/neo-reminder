require 'test/unit'
require 'json'

class TestV2 < Test::Unit::TestCase

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

  def test_scenario_v2
    # クリア
    json_data = '{"command":"clear","options":{"target":"all"}}'
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]

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
    assert_equal false, result[:list][0][:finished]

    # もう1件登録する
    json_data = '{"command":"create","options":{"title":"打ち上げに行く"}}'
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert is_iso_date(result[:created_at])

    # unfinished で取得してみる
    json_data = '{"command":"list","options":{"condition":"unfinished"}}'
    result = _call_svc(json_data)

    assert_equal 2, result[:list].length
    assert_equal 'テスト', result[:list][0][:title]
    assert_equal false, result[:list][0][:finished]
    assert result[:list][0][:term] == nil || result[:list][0][:term] == ''
    assert_equal '打ち上げに行く', result[:list][1][:title]
    assert result[:list][1][:term] == nil || result[:list][1][:term] == ''
    assert_equal false, result[:list][1][:finished]

    entity_id = result[:list][0][:id]
    entity2_id = result[:list][1][:id]

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
    assert is_iso_date(result[:updated_at])

    # 監視
    json_data = {
      command: :observe,
      options: {
        current_time: '2018-03-20T16:59:59+09:00',
        lat:          0.0,
        long:         0.0
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 0, result[:notifications]&.length

    # 監視（通知日時到来）
    json_data = {
      command: :observe,
      options: {
        current_time: '2018-03-20T17:00:00+09:00',
        lat:          0.0,
        long:         0.0
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 1, result[:notifications]&.length
    assert_not_nil result[:notifications][0][:subject]
    assert_not_nil result[:notifications][0][:body]

    # 監視（一回通知されたものは２回通知されないこと）
    json_data = {
      command: :observe,
      options: {
        current_time: '2018-03-20T17:01:00+09:00',
        lat:          0.0,
        long:         0.0
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 0, result[:notifications]&.length

    # もう一つのリマインダーを編集し、１の期限到来と２の通知日時が重なるようにする
    json_data = {
      command: :edit,
      options: {
        id:              entity2_id,
        title:           'パンを買いに行く',
        notify_datetime: '2018-03-21T10:31:00+09:00',
        term:            '2019-03-23T23:59:59+09:00',
        memo:            '自宅の食料が無くなるから買いに行く'
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert is_iso_date(result[:updated_at])

    # 監視（通知日時到来、期日到来）
    json_data = {
      command: :observe,
      options: {
        current_time: '2018-03-21T10:31:00+09:00',
        lat:          0.0,
        long:         0.0
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 2, result[:notifications]&.length
    assert_not_nil result[:notifications][0][:subject]
    assert_not_nil result[:notifications][0][:body]
    assert_not_nil result[:notifications][1][:subject]
    assert_not_nil result[:notifications][1][:body]

    # 監視（一回期日通知されたものは２回期日通知されないこと）
    json_data = {
      command: :observe,
      options: {
        current_time: '2018-03-21T10:32:00+09:00',
        lat:          0.0,
        long:         0.0
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 0, result[:notifications]&.length

    # 監視（２の期日未到来）
    json_data = {
      command: :observe,
      options: {
        current_time: '2019-03-31T23:59:58+09:00',
        lat:          0.0,
        long:         0.0
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 0, result[:notifications]&.length

    # 完了にする
    json_data = %Q/{"command":"finish","options":{"id":#{entity2_id}}}/
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert is_iso_date(result[:finished_at])

    # 監視（２の期日到来）
    json_data = {
      command: :observe,
      options: {
        current_time: '2019-03-31T23:59:59+09:00',
        lat:          0.0,
        long:         0.0
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 0, result[:notifications]&.length # 完了になっているので通知は来ない
  end

  def is_iso_date(iso_date)
    iso_date =~ /\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\+\d\d:\d\d/
  end
end

