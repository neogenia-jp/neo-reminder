require_relative '../../src/yamamoto/data_accessor'
require 'test/unit'

class MainTest < Test::Unit::TestCase
  def test_main
    assert_equal '{status: "ok"}', ::Kamada::main("")
  end
end

