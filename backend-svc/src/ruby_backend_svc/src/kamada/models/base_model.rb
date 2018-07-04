require 'json'
require_relative '../data_accessor'
require_relative '../extend/string_ext'

module Yamamoto
  class BaseModel
    attr_reader :new_record

    # コンストラクタ
    # @param contents [Hash] 初期値(define_attributesに定義したものが有効となる)
    def initialize(contents={})
      self.class.attributes.each do |attr|
        self.send("#{attr}=", contents[attr.to_s])
      end
      @new_record = true
      yield(self) if block_given?
    end

    # データアクセサクラス取得
    # @return [DataAccessor]
    def self.data_accessor
      @data_accessor ||= DataAccessor.new(model_dir_name)
    end

    # モデルのディレクトリ名称
    # @return [String] モデルのディレクトリ名
    def self.model_dir_name
      self.to_s.split('::').last.to_snake_case
    end

    # 1件検索
    # @param find [Integer] ID
    # @return [Model] モデル
    def self.find(id)
      result = data_accessor.read(id)
      self.new(result) do
        @new_record = false
      end
    end

    # 保存
    # @return [Model] モデル
    def save
      if @new_record
        self.class.data_accessor.create(to_hash)
      else
        update
      end
    end

    # アップデート
    # @return [Model] モデル
    def update
      self.class.data_accessor.update(to_hash, self.id); self
    end

    # ハッシュ化（{define_attributesで定義したattribute => 値}の形に変換する）
    # @return [Hash]
    def to_hash
      self.class.attributes.inject({}) do |result, attr|
        result[attr] = self.send("#{attr}"); result
      end
    end

    # JSON化（{define_attributesで定義したattributeをJSON文字列に変換する）
    # @return [String]
    def to_json
      to_hash.to_json
    end

    def self.define_attributes(*attrs)
      attrs.each do |attr|
        attr_accessor attr
      end
      self.attributes += attrs.dup
    end

    def self.attributes
      @attributes || []
    end

    def self.attributes=(attrs)
      @attributes = attrs
    end
  end
end
