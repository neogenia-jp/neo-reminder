require 'test/unit'
Dir[File.join(File.dirname(__FILE__), '../../src/kamada/*.rb')].each { |file| require file }

module Kamada
  class BaseTest < Test::Unit::TestCase
    def setup
      @data_accessor = DataAccessor.instance
      @data_path = "#{File.join(File.dirname(__FILE__), 'data')}"
      @data_accessor.instance_eval "@data_base_path = '#{@data_path}'"
    end

    def teardown
      # テストファイル削除
      file_names = Dir.glob(File.join(File.dirname(__FILE__), './data/*'))
      file_names.each do |name|
        File.delete(name)
      end
    end

    def create_test_data(file_name, contents)
      File.write(File.join(@data_path, file_name), contents)
    end
  end
end

