require 'test/unit'
require_relative '../../../src/yamamoto/models/base'

module Yamamoto
  module Models
    class BaseTest < Test::Unit::TestCase
      def setup
        Base.base_path =File.join(File.dirname(__FILE__), '../data')
      end
    end
  end
end

