require 'time'
require 'json'
require 'fileutils'
require_relative '../extend/string_ext'

module Yamamoto
  module Models
    class BasicModel
      @@basic_attrs = [:id, :created_at, :updated_at]
      @@base_path = File.join(File.dirname(__FILE__), '../data')

      # コンストラクタ
      # @param init_values [Hash] 初期値
      def initialize(init_values={})
        self.class.attribute_names.each do |attr|
          self.class.instance_eval { attr_accessor attr.to_sym }
          send("#{attr}=", init_values[attr])
        end
      end

      def save
        # 全モデル共通のアトリビュートを設定
        _id = self.id || next_id
        set_base_attribute(_id)

        # データ保存
        # （ディレクトリがない場合は作る）
        FileUtils.mkdir_p(self.class.dir_path)
        File.write(self.class.file_path(_id), self.to_h.to_json)

        self.class.find(_id)
      end

      # アトリビュートをハッシュ化する
      # @return [Hash] {アトリビュート名: 値, ...}
      def to_h
        self.class.attribute_names.inject({}) do |result, key|
          result[key] = self.send("#{key}") if key != :id
          result
        end
      end

      # データを保存するディレクトリパス
      # @return [String]
      def self.dir_path
        File.join(@@base_path, self.to_s.split('::').last.to_snake_case)
      end

      # アトリビュートの名称一覧取得
      # @return [Array] アトリビュート名の配列
      def self.attribute_names
        @@basic_attrs + (self.class_variable_get(:@@attrs) || [])
      end

      def self.find(id)
        contents = File.read(self.file_path(id))
        init_values = JSON.parse(contents, symbolize_names: true).merge(id: id)
        self.new(init_values)
      end

      def self.all
        id_list.map do |id|
          find(id)
        end
      end

      def self.where(**attrs)
        # eq
        # lt
        # gt
        yield(all) if block_given?
      end

      # ファイルのパス
      def self.file_path(id)
        File.join(self.dir_path, "#{id}.json")
      end

      private

      def set_base_attribute(id, time=Time.now)
        # id設定
        self.id = id

        # 作成日時、更新日時設定
        self.created_at = time.iso8601 unless File.exist?(self.class.file_path(self.id))
        self.updated_at = time.iso8601
      end

      # 次のID
      # @return [Integer] 次のID
      def next_id
        ids = id_list.map{|i| i.to_i}
        ids.empty? ? 1 : ids.max + 1
      end

      # ファイルIDリスト
      def id_list
        Dir.glob(File.join(self.class.dir_path, "*")).map { |f_name| File.basename(f_name, ".json").to_i }.sort
      end
    end
  end
end

