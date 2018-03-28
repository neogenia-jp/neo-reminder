require 'json'

module Yamamoto
  class DataAccessor
    def initialize
      @data_base_path = File.expand_path("./data/")
    end

    # ファイル読み込み
    # @param id [Integer] ファイルID
    # @return [String] 読み込んだファイルの内容
    def read(id)
      File.read(File.join(@data_base_path, "#{id}.json"))
    end

    # 全件取得
    # @return [Array] 読み込んだファイルの内容の配列
    def all_read
      id_list.inject([]) do |result, id|
        result << read(id); result
      end
    end

    # 新規作成
    # @return [String] 書き込んだ内容
    def create(json_str)
      # TODO: ファイルロック
      File.write(File.join(@data_base_path, "#{next_id}.json"), json_str)
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

