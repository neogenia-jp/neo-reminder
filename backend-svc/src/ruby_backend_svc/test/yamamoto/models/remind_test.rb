require_relative './base_test'
require_relative '../../../src/yamamoto/models/remind'

module Yamamoto
  module Models
    class RemindTest < BaseTest

      def test_find
        result = Remind.find(1)
        binding.pry
        assert_equal 1, result.id
        assert_equal 'テスト', result.title
        assert_equal nil, result.updated_at
      end
    end
  end
end

