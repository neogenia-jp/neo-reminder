require_relative './base_test'
require_relative '../../src/yamamoto/delete_api'

module Yamamoto
  class DeleteApiTest < BaseTest
    def setup
      super
      create_test_data('1.json', '{"title":"xxxxxx","term":"2018-03-20T19:32:00+09:00"}')
      create_test_data('2.json', '{"title":"yyyyyy","term":"2018-03-20T19:32:00+09:00"}')
    end


    def test_delete
      json_data = {'options' => {'id' => '1'}}
      result = DeleteApi.new.run(json_data)
      assert_equal 'ok', result[:status]
      assert_equal '', result[:message]
      refute File.exist?(File.join(@data_path, '1.json'))
    end

    #def test_delete_error
    #  json_data = {'options' => {'id' => '1'}}
    #  result = DeleteApi.new.run(json_data)
    #  assert_equal 'error', result[:status]
    #  assert_equal '', result[:message]
    #end
  end
end

