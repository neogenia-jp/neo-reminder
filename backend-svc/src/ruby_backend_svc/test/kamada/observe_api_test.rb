require_relative './base_test'

module Yamamoto
  class ObserveApiTest < BaseTest
    def setup
      super
      create_test_data('1.json', '{"title":"xxxxxx","memo":"xxxxxxの本文","notify_datetime":"2018-04-30T23:59:59+09:00"}')
      create_test_data('2.json', '{"title":"yyyyyy","memo":"yyyyyyの本文","notify_datetime":"2018-05-01T00:00:00+09:00"}')
      create_test_data('3.json', '{"title":"zzzzzz","memo":"zzzzzzの本文","notify_datetime":"2018-05-01T00:00:00+09:00","notified":1}')
      create_test_data('4.json', '{"title":"aaaaaa","memo":"aaaaaaの本文","notify_datetime":"2018-05-01T00:00:01+09:00"}')
    end

    def test_通知日時に到達しているリマインダーが取得できること
      result = ObserveApi.new.run(JSON.parse('{"options":{"current_time":"2018-05-01T00:00:00+09:00","lat":0.0,"long":0.0}}'))
      assert_equal('ok',result[:status])
      assert_equal('',result[:message])
      assert_equal(2, result[:notifications].length)
      assert_equal('xxxxxx', result[:notifications][0][:subject])
      assert_equal('xxxxxxの本文', result[:notifications][0][:body])
      assert_equal({}, result[:notifications][0][:svc_data])
      assert_equal('yyyyyy', result[:notifications][1][:subject])
      assert_equal('yyyyyyの本文', result[:notifications][1][:body])
      assert_equal({}, result[:notifications][1][:svc_data])
    end

  end
end
