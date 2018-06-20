require 'test/unit'
Dir[File.join(File.dirname(__FILE__), '../../src/yoneoka/*.rb')].each {|file| require file}

module Yoneoka
  class MainTest < Test::Unit::TestCase

    #TODO テストをコピペでとりあえず走らせるようにした。あとで整理。

    def setup
      p "setup(^o^)//"
      @data_accessor = DataAccessor.instance
      @data_path = "#{File.join(File.dirname(__FILE__), 'data')}"
      @data_accessor.instance_eval "@data_base_path = '#{@data_path}'"
      create_test_data('1.json', '{"title":"xxxxxx","term":"' + DateTime.now.iso8601 + '","finished_at":"2018-03-22T19:32:00+09:00"}')
      create_test_data('2.json', '{"title":"yyyyyy","term":"2018-03-20T19:32:00+09:00"}')
      create_test_data('3.json', '{"title":"zzzzzz","term":"2018-03-21T19:32:00+09:00"}')
      create_test_data('4.json', '{"title":"aaaaaa","term":"2018-03-21T19:32:00+09:00","finished_at":"2018-03-22T19:32:00+09:00"}')
    end

    def teardown
      # テストファイル削除
      file_names = Dir.glob(File.join(File.dirname(__FILE__), './data/*'))
      file_names.each do |name|
        File.delete(name)
      end
    end

    def test_main3
      result = ListApi.new::run(JSON.parse('{"options":{"condition":"all"}}'))
      p result
    end

    def test_main1
      # result = ClearApi.new::run(JSON.parse('{"options":{"target":"all"}}'))
      result = ListApi.new::run(JSON.parse('{"options":{"condition":"all"}}'))
      p '-----'
      p result
      p '-----'
      # assert_equal '{status: "ok"}', ::Kamadsetup a::main("")
    end

    def test_main2
      p '-----'
      result = ListApi.new::run(JSON.parse('{"options":{"condition":"all"}}'))
      p result
      p '-----'
      result = ClearApi.new::run(JSON.parse('{"options":{"target":"all"}}'))
      p result
      p '-----'
      result = ListApi.new::run(JSON.parse('{"options":{"condition":"all"}}'))
      p result
      p '-----'
    end

    def test_main4
      p '-----'
      result = FinishApi.new::run(JSON.parse('{"options":{"id":"1"}}'))
      p result
      p '-----'
      result = FinishApi.new::run(JSON.parse('{"options":{"id":"4"}}'))
      p result
      p '-----'
      result = ListApi.new::run(JSON.parse('{"options":{"condition":"all"}}'))
      p result
    end

    private

    def create_test_data(name, data)
      File.write(File.join(@data_path, name), data)
    end

  end
end

