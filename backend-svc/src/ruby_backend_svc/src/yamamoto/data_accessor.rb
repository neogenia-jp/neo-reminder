require 'json'
require 'singleton'

module Yamamoto
  class DataAccessor
    include Singleton
    def initialize
      @data_base_path = File.join(File.dirname(__FILE__), 'data')
    end

    # データ読み込み
    # @param id [Integer] ファイルID
    # @return [Hash] 読み込んだファイルの内容
    def read(id)
      result = JSON.parse(File.read(File.join(@data_base_path, "#{id}.json")))
      result['id'] = id
      result
    end

    # 全件取得
    # @return [Array] 読み込んだファイルの内容の配列
    def all_read
      id_list.inject([]) do |result, id|
        result << read(id); result
      end
    end

    # 新規作成
    # @param contents [Hash] ファイルに書き込む内容
    # @return [Integer] 書き込んだバイト数
    def create(contents)
      # TODO: ファイルの存在確認
      File.write(File.join(@data_base_path, "#{next_id}.json"), contents.to_json)
    end

    # 次のID
    # @return [Integer] 次のID
    def next_id
      ids = id_list.map{|i| i.to_i}
      ids.empty? ? 1 : ids.max + 1
    end

    # ファイルIDリスト
    def id_list
      Dir.glob(File.join(@data_base_path, "*")).map { |f_name| File.basename(f_name, ".json").to_i }.sort
    end

  end
end

