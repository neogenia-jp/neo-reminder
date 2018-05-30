require 'json'
require 'singleton'
require 'time'

module Yoneoka
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
    # @param id [Integer] ファイルID（指定しない場合は次のIDを採番する）
    # @return [Integer] 書き込んだバイト数
    def create(contents, id=nil)
      # IDがファイル名と二重管理になるため、消しておく
      contents.delete_if {|key, val| key == :id || key == 'id'}

      id = next_id unless id

      # 作成日付を追加
      contents['created_at'] = Time.now.iso8601

      # TODO: ファイルの存在確認
      File.write(File.join(@data_base_path, "#{id}.json"), contents.to_json)
    end

    # 更新
    # @param contents [Hash] ファイルに書き込む内容
    # @param id [Integer] ファイルID（指定しない場合は次のIDを採番する）
    # @return [Integer] 書き込んだバイト数
    def update(contents, id)
      # IDがファイル名と二重管理になるため、消しておく
      contents.delete_if {|key, val| key == :id || key == 'id'}

      # 更新日付を追加
      contents['updated_at'] = Time.now.iso8601

      # 更新対象に指定された値を更新する
      # TODO: ファイルの存在確認
      target = read(id)
      File.write(File.join(@data_base_path, "#{id}.json"), target.merge(contents).to_json)
    end

    # 削除
    # @param id [Integer] ファイルID
    def delete(id)
      # TODO: ファイルの存在確認
      File.delete(File.join(@data_base_path, "#{id}.json"))
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

