require 'test/unit'
require 'fileutils'

module Yamamoto
  class BaseModelTest < Test::Unit::TestCase
    def setup
      DataAccessor.class_variable_set(:@@data_path, File.join(File.dirname(__FILE__), '../data'))
    end

    def teardown
      # テストファイル削除
      Dir.glob(File.join(File.dirname(__FILE__), '../data/*')).each do |path|
        FileUtils.rm(path)
      end
    end

    def create_test_data(file_name, contents)
      File.write(File.join(@data_path, file_name), contents)
    end
  end
end

