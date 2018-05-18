require 'test/unit'
require 'fileutils'
require 'json'
require_relative '../../../src/yamamoto/models/basic_model'
#Dir[File.join(File.dirname(__FILE__), '../../src/yamamoto/models/*.rb')].each { |file| require file }

module Yamamoto
  class ModelTestBase < Test::Unit::TestCase
    Models::BasicModel.class_variable_set(:@@base_path, File.join(File.dirname(__FILE__), 'data'))
    def setup
      #@data_path = "#{File.join(File.dirname(__FILE__), 'data')}"
      #@data_accessor.instance_eval "@data_base_path = '#{@data_path}'"
    end

    def teardown
      # テストファイル削除
      FileUtils.rm_r(Dir.glob(File.join(File.dirname(__FILE__), '../data/*')))
    end

    def create_test_data(file_id, contents)
      file_path = File.join(Models::BasicModel.class_variable_get(:@@base_path), "#{file_id}.json")
      File.write(file_path, contents)
    end

    def file_read(id)
      file_path = File.join(Models::BasicModel.class_variable_get(:@@base_path), "#{id}.json")
      JSON.parse(File.read(file_path))
    end
  end
end

