module BitFieldSupport
  extend ActiveSupport::Concern

  module ClassMethods
    # プロパティをビットフィールドとして使用できるようにする
    # @param col_name [Symbol|String] 対象のプロパティ名  ※必須
    # @param model    [Class]         ビットフィールドに対応するモデルクラス（ActiveHash のようなクラス） ※省略時はプロパティ名より自動判定
    # @param ids      [Array]         ビットフィールドにマッピングする値のリスト  ※省略時はモデルクラスに定義されている全ID
    # @param suffix   [Symbol|String] 追加されるメソッド名のサフィックス  ※省略時は 'selection'
    def bit_field_attr(col_name, model: nil, ids: nil, suffix: nil)
      ids = ids&.to_a || (model || col_name.to_s.singularize.camelize.constantize).all
      plur_col_name = col_name.to_s.pluralize
      suffix = suffix || :selection
      self.class_eval do
        # UserTypeまたはUserTypeのIDの配列からuser_typesへの変換メソッド
        # @param val [UserType|Any] UserTypeまたはUserTypeのIDの配列  ex. ["2", "4", "5"]
        define_method "#{plur_col_name}_#{suffix}=" do |values|
          bits = 0
          Array(values).each do |t|
            v = t.respond_to?(:id) ? t.id : t.to_i
            next if v<1
            bits |= (1 << (v - 1))
          end
          self.send "#{col_name}=", bits
        end

        # user_typesからUserTypeモデルの配列への変換メソッド
        # @return [Array] UserTypeモデルの配列
        define_method "#{plur_col_name}_#{suffix}" do
          return nil if self.send(col_name).nil?

          ids.each_with_object([]) do |t, arr|
            v = t.respond_to?(:id) ? t.id : t.to_i
            next if self.send(col_name) & (1 << (v - 1)) == 0
            arr << t
          end
        end
      end
    end
  end
end