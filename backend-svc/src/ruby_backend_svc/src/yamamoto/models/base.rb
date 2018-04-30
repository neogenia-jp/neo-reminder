require 'json'

module Yamamoto
  module Models
    class Base
      @@base_attributes = [
          :id,
          :created_at,
          :updated_at
      ]
      attr_accessor *@@base_attributes

      # データ保存場所ルートパス
      @@base_path = File.join(File.dirname(__FILE__), '../data')

      # コンストラクタ
      def initialize(model_attributes, contents)
        # 初期値設定
        attributes = model_attributes + @@base_attributes
        if contents.is_a?(Hash)
          attributes.each do |attr|
            if self.respond_to?("#{attr}=")
              send("#{attr}=", contents[attr])
            end
          end
        end
      end

      class << self
        def find(id)
          contents = JSON.parse(File.read(File.join(@@base_path, derived_model.class_eval('@@model_dir_name'), "#{id}.json")), symbolize_names: true)
          contents[:id] = id

          derived_model.new(contents)
        end

        def all
          id_list.inject([]) do |result, id|
            result << read(id); result
          end
        end

        def base_path=(val)
          @@base_path = val
        end

        def derived_model
          Object.const_get(name)
        end
      end

      def create

      end

      def update

      end

      def attributes

      end
    end
  end
end

