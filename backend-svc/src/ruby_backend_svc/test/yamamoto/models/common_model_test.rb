require 'test/unit'
require 'fileutils'
require 'json'
require_relative './base_model_test'
require_relative '../../../src/yamamoto/models/basic_model'
require 'pry'

module Yamamoto
  class CommonModelTest < Test::Unit::TestCase
    Models::BasicModel.class_variable_set(:@@base_path, File.join(File.dirname(__FILE__), '../data'))

    class CommonModel < Models::BasicModel
      @@attrs = [
          :dt,
          :string,
      ]
    end

    def teardown
      # テストファイル削除
      FileUtils.rm_r(Dir.glob(File.join(CommonModel.dir_path, '*')))
    end

    # テストデータ作成
    def create_test_data(file_id, contents)
      FileUtils.mkdir_p(CommonModel.dir_path)
      File.write(CommonModel.file_path(file_id), contents)
    end

    def test_initialize_初期値なし
      m = CommonModel.new
      assert_equal nil, m.id
      assert_equal nil, m.dt
      assert_equal nil, m.string
      assert_equal nil, m.created_at
      assert_equal nil, m.updated_at
    end

    def test_initialize_初期値あり
      m = CommonModel.new(
          id: 1,
          dt: Time.new(2018, 1, 1, 0, 0, 0).iso8601,
          string: "テストテスト\nテスト",
          created_at: Time.new(2018, 1, 2, 0, 0, 0).iso8601,
          updated_at: Time.new(2018, 1, 3, 0, 0, 0).iso8601
      )

      assert_equal 1, m.id
      assert_equal Time.new(2018, 1, 1, 0, 0, 0).iso8601, m.dt
      assert_equal "テストテスト\nテスト", m.string
      assert_equal Time.new(2018, 1, 2, 0, 0, 0).iso8601, m.created_at
      assert_equal Time.new(2018, 1, 3, 0, 0, 0).iso8601, m.updated_at
    end

    def test_save_新規作成
      m = CommonModel.new(
          dt: Time.new(2018, 1, 1, 0, 0, 0).iso8601,
          string: "テストテスト\nテスト",
      )

      # 初期値チェック
      assert_equal nil, m.id
      assert_equal Time.new(2018, 1, 1, 0, 0, 0).iso8601, m.dt
      assert_equal "テストテスト\nテスト", m.string
      assert_equal nil,m.created_at
      assert_equal nil,m.updated_at
      m.save

      # モデルのアトリビュートチェック
      assert_equal 1, m.id # idが割り振られるはず
      assert m.created_at
      assert m.updated_at
      assert_equal m.created_at, m.updated_at # 作成日時、更新日時は同じのはず
    end

    def test_save_更新
      create_test_data(1, '{"dt":"2018-01-01T00:00:00+09:00","string":"テストテスト\nテスト","created_at":"2018-01-02T00:00:00+09:00","updated_at":"2018-01-03T00:00:00+09:00"}')
      m = CommonModel.find(1)

      # 初期値チェック
      assert_equal 1, m.id
      assert_equal '2018-01-01T00:00:00+09:00', m.dt
      assert_equal "テストテスト\nテスト", m.string
      assert_equal '2018-01-02T00:00:00+09:00',m.created_at
      assert_equal '2018-01-03T00:00:00+09:00',m.updated_at

      # 更新後の値チェックのために更新前の値を保持しておく
      before_created_at = m.created_at
      before_updated_at = m.updated_at

      # 更新する
      m.dt = Time.new(2018, 1, 4, 0, 0, 0).iso8601
      m.string = "てすとてすと\nてすと"
      m.save

      # モデルのアトリビュートチェック
      assert_equal 1, m.id
      assert_equal '2018-01-04T00:00:00+09:00', m.dt
      assert_equal "てすとてすと\nてすと", m.string
      assert_equal before_created_at, m.created_at
      assert_not_equal before_updated_at, m.updated_at
    end

    def test_find_データありの場合
      create_test_data(1, '{"dt":"2018-01-01T00:00:00+09:00","string":"テストテスト\nテスト","created_at":"2018-01-02T00:00:00+09:00","updated_at":"2018-01-03T00:00:00+09:00"}')
      m = CommonModel.find(1)

      assert_equal 1, m.id
      assert_equal '2018-01-01T00:00:00+09:00', m.dt
      assert_equal "テストテスト\nテスト", m.string
      assert_equal '2018-01-02T00:00:00+09:00', m.created_at
      assert_equal '2018-01-03T00:00:00+09:00', m.updated_at
    end

    def test_find_データなしの場合
      assert_nil CommonModel.find(1)
    end

    def test_all
      create_test_data(1, '{"dt":"2018-01-01T00:00:00+09:00","string":"テストテスト\nテスト","created_at":"2018-01-02T00:00:00+09:00","updated_at":"2018-01-03T00:00:00+09:00"}')
      create_test_data(2, '{"dt":"2018-01-01T00:00:00+09:00","string":"てすとてすと\nてすと","created_at":"2018-01-02T00:00:00+09:00","updated_at":"2018-01-03T00:00:00+09:00"}')

      models = CommonModel.all
      assert_equal 2, models.length

      models.sort_by! { |m| m.id }
      assert_equal 1, models[0].id
      assert_equal '2018-01-01T00:00:00+09:00', models[0].dt
      assert_equal "テストテスト\nテスト", models[0].string
      assert_equal '2018-01-02T00:00:00+09:00', models[0].created_at
      assert_equal '2018-01-03T00:00:00+09:00', models[0].updated_at

      assert_equal 2, models[1].id
      assert_equal '2018-01-01T00:00:00+09:00', models[1].dt
      assert_equal "てすとてすと\nてすと", models[1].string
      assert_equal '2018-01-02T00:00:00+09:00', models[1].created_at
      assert_equal '2018-01-03T00:00:00+09:00', models[1].updated_at
    end

    def test_where
      create_test_data(1, '{"dt":"2018-01-01T00:00:00+09:00","string":"テスト","created_at":"2018-01-02T00:00:00+09:00","updated_at":"2018-01-03T00:00:00+09:00"}')
      create_test_data(2, '{"dt":"2018-01-02T00:00:00+09:00","string":"てすと","created_at":"2018-01-02T00:00:00+09:00","updated_at":"2018-01-03T00:00:00+09:00"}')
      create_test_data(3, '{"dt":"2018-01-03T00:00:00+09:00","string":"てすと","created_at":"2018-01-02T00:00:00+09:00","updated_at":"2018-01-03T00:00:00+09:00"}')

      # データなし
      models = CommonModel.where(string: "T")
      assert_equal 0, models.length

      # イコール
      models = CommonModel.where(string: "てすと")
      assert_equal 2, models.length
      assert_equal "てすと", models[0].string
      assert_equal "てすと", models[1].string

      # 大なり
      binding.pry
      models = CommonModel.where(dt_gt: Time.new(2018, 1, 2, 0, 0, 0).iso8601)
      assert_equal 1, models.length
      assert_equal "2018-01-03T00:00:00+09:00", models[0].dt

      # 大なりイコール
      models = CommonModel.where(dt_gteq: Time.new(2018, 1, 2, 0, 0, 0).iso8601)
      models.sort_by! { |m| m.dt }
      assert_equal 2, models.length
      assert_equal "2018-01-02T00:00:00+09:00", models[0].dt
      assert_equal "2018-01-03T00:00:00+09:00", models[1].dt

      # 小なり
      models = CommonModel.where(dt_lt: Time.new(2018, 1, 2, 0, 0, 0).iso8601)
      assert_equal 1, models.length
      assert_equal "2018-01-01T00:00:00+09:00", models[0].dt

      # 小なりイコール
      models = CommonModel.where(dt_lteq: Time.new(2018, 1, 2, 0, 0, 0).iso8601)
      models.sort_by! { |m| m.dt }
      assert_equal 2, models.length
      assert_equal "2018-01-01T00:00:00+09:00", models[0].dt
      assert_equal "2018-01-02T00:00:00+09:00", models[1].dt

      # 複数条件
      models = CommonModel.where(dt_lteq: Time.new(2018, 1, 2, 0, 0, 0).iso8601, string: "テスト")
      assert_equal 1, models.length
      assert_equal "2018-01-01T00:00:00+09:00", models[0].dt
      assert_equal "テスト", models[0].string
    end
  end
end

