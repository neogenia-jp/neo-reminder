require 'test/unit'
require 'json'

class TestV3 < Test::Unit::TestCase

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

  def test_scenario_v3
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

    # 編集（位置情報有り）
    json_data = {
      command: :edit,
      options: {
        id:              entity_id,
        title:           'テストコードを書く',
        notify_datetime: '2018-03-20T17:00:00+09:00',
        term:            '2018-03-21T10:30:00+09:00',
        memo:            '実装した新機能のテストコードがまだないので書く',
        lat:             34.663601,
        long:            135.496921,
        radius:          50,
        direction:       :in
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert is_iso_date(result[:updated_at])

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
    assert_equal 34.663601, result[:lat]
    assert_equal 135.496921, result[:long]
    assert_equal 50, result[:radius]
    assert_equal 'in', result[:direction]
    assert result[:finished_at] == nil || result[:finished_at] == ''
    assert is_iso_date(result[:created_at])
    entity1_created_at = result[:created_at]

    # 監視(範囲に入っていないとき)
    json_data = {
      command: :observe,
      options: {
        current_time: '2018-03-20T16:58:59+09:00',
        lat:          34.663509,
        long:         135.497475  # 約51m の距離
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 0, result[:notifications]&.length

    # 監視(範囲に入ったとき)
    json_data = {
      command: :observe,
      options: {
        current_time: '2018-03-20T16:59:59+09:00',
        lat:          34.663509,
        long:         135.497445  # 約49m の距離
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 1, result[:notifications]&.length
    assert_not_nil result[:notifications][0][:subject]
    assert_not_nil result[:notifications][0][:body]

    # 半径100m, dir=out に変更
    json_data = {
      command: :edit,
      options: {
        id:              entity_id,
        title:           '日本に電話する',
        notify_datetime: '2018-03-20T17:02:00+09:00',
        term:            '2018-03-21T10:30:00+09:00',
        memo:            'ブラジルの人きこえますか〜',
        lat:             -15.791726,
        long:            -47.889573,
        radius:          100,
        direction:       :out
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert is_iso_date(result[:updated_at])

    # 監視(範囲に入っているとき)
    json_data = {
      command: :observe,
      options: {
        current_time: '2018-03-20T16:58:59+09:00',
        lat:          -15.792481,
        long:         -47.889934  # 約92m の距離
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 0, result[:notifications]&.length

    # 監視(範囲から出たとき)
    json_data = {
      command: :observe,
      options: {
        current_time: '2018-03-20T16:59:59+09:00',
        lat:          -15.792591,
        long:         -47.889934  # 約103m の距離
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 1, result[:notifications]&.length
    assert_not_nil result[:notifications][0][:subject]
    assert_not_nil result[:notifications][0][:body]

    # スヌーズ
    json_data = {
      command: :snooze,
      options: {
        id: entity_id,
        current_time: '2018-03-20T17:00:00+09:00',
        minutes: 5
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]

    # 監視(範囲から出ているが、スヌーズ時刻になっていない)
    json_data = {
      command: :observe,
      options: {
        current_time: '2018-03-20T17:01:00+09:00',
        lat:          -15.792591,
        long:         -47.889934  # 約103m の距離
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 0, result[:notifications]&.length

    # 監視(範囲から出ている、スヌーズ時刻になっていない、通知期限到来)
    json_data = {
      command: :observe,
      options: {
        current_time: '2018-03-20T17:02:00+09:00',
        lat:          -15.792591,
        long:         -47.889934  # 約103m の距離
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 1, result[:notifications]&.length
    assert_not_nil result[:notifications][0][:subject]
    assert_not_nil result[:notifications][0][:body]

    # 監視(範囲から出ている、まだスヌーズ時刻になっていない)
    json_data = {
      command: :observe,
      options: {
        current_time: '2018-03-20T17:03:00+09:00',
        lat:          -15.792591,
        long:         -47.889934  # 約103m の距離
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 0, result[:notifications]&.length

    # 監視(範囲から出ている、まだスヌーズ時刻になっていない)
    json_data = {
      command: :observe,
      options: {
        current_time: '2018-03-20T17:04:00+09:00',
        lat:          -15.792591,
        long:         -47.889934  # 約103m の距離
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 0, result[:notifications]&.length

    # 監視(範囲から出ている、スヌーズ時刻到来)
    json_data = {
      command: :observe,
      options: {
        current_time: '2018-03-20T17:05:00+09:00',
        lat:          -15.792591,
        long:         -47.889934  # 約103m の距離
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 1, result[:notifications]&.length

    # 監視(範囲から出ている、さらに5分経過)
    json_data = {
      command: :observe,
      options: {
        current_time: '2018-03-20T17:10:00+09:00',
        lat:          -15.792591,
        long:         -47.889934  # 約103m の距離
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 0, result[:notifications]&.length

    # 再度スヌーズ
    json_data = {
      command: :snooze,
      options: {
        id: entity_id,
        current_time: '2018-03-20T17:10:30+09:00',
        minutes: 2
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]

    # 監視(範囲から出ている、30秒経過)
    json_data = {
      command: :observe,
      options: {
        current_time: '2018-03-20T17:11:00+09:00',
        lat:          -15.792591,
        long:         -47.889934  # 約103m の距離
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 0, result[:notifications]&.length

    # 監視(範囲から出ている、1分30秒経過)
    json_data = {
      command: :observe,
      options: {
        current_time: '2018-03-20T17:12:00+09:00',
        lat:          -15.792591,
        long:         -47.889934  # 約103m の距離
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 0, result[:notifications]&.length

    # 監視(範囲から出ている、2分30秒経過)
    json_data = {
      command: :observe,
      options: {
        current_time: '2018-03-20T17:13:00+09:00',
        lat:          -15.792591,
        long:         -47.889934  # 約103m の距離
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 1, result[:notifications]&.length

    # 再度スヌーズ
    json_data = {
      command: :snooze,
      options: {
        id: entity_id,
        current_time: '2018-03-20T17:13:30+09:00',
        minutes: 1
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]

    # 元データ変更
    json_data = {
      command: :edit,
      options: {
        id:              entity_id,
        title:           'テストコードを書く',
        notify_datetime: '2018-03-20T17:16:00+09:00',
        term:            '2018-03-21T10:30:00+09:00',
        memo:            '実装した新機能のテストコードがまだないので書く',
        lat:             34.663601,
        long:            135.496921,
        radius:          50,
        direction:       :in
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert is_iso_date(result[:updated_at])

    # 監視（変更前のスヌーズ時刻到来）
    json_data = {
      command: :observe,
      options: {
        current_time: '2018-03-20T17:15:00+09:00',
        lat:          34.663601,
        long:         135.496921,
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 0, result[:notifications]&.length  # 元データ変更してるので通知されない

    # 監視（変更後の通知時刻到来）
    json_data = {
      command: :observe,
      options: {
        current_time: '2018-03-20T17:16:00+09:00',
        lat:          34.663601,
        long:         135.496921,
      }
    }
    result = _call_svc(json_data)

    assert_equal 'ok', result[:status]
    assert_equal 1, result[:notifications]&.length  # 元データ変更してるので通知されない

  end

  def is_iso_date(iso_date)
    iso_date =~ /\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\+\d\d:\d\d/
  end
end

