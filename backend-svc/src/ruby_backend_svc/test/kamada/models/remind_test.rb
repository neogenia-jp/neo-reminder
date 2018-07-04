require 'test/unit'
require_relative './base_model_test'
require_relative '../../../src/yamamoto/models/remind'

module Kamada
  class RemindTest < BaseModelTest
    def test_initialize_初期値あり
      m = Remind.new
      assert_equal nil, m.id
      assert_equal nil, m.title
      assert_equal nil, m.notify_datetime
      assert_equal nil, m.term
      assert_equal nil, m.memo
      assert_equal nil, m.finished_at
      assert_equal nil, m.created_at
    end

    def test_initialize_初期値なし
      m = Remind.new(id: 1, titile: "aaa", notify_datetime: Time.new(2018, 1, 1, 12, 34, 56).iso8601, term: "abc", )
      assert_equal 1, m.id
      assert_equal 'aaa', m.title
      assert_equal '201', m.notify_datetime
      assert_equal nil, m.term
      assert_equal nil, m.memo
      assert_equal nil, m.finished_at
      assert_equal nil, m.created_at
    end

    def test_find
    end

    def test_save_新規レコードの場合
    end

    def test_save_存在するレコードの場合
    end

  end
end
