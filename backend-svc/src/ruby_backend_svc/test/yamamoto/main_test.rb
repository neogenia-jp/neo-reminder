# テスト対象のモジュールをロード
_dir = File.dirname(__FILE__)
_route = File.basename _dir
Dir["#{_dir}/../../src/#{_route}/*.rb"].each do |f|
  if f.index('entrypoint.rb').nil?
    require File.expand_path f
  end
end

require 'test/unit'

class MainTest < Test::Unit::TestCase
  def test_main
    assert_equal '{status: "ok"}', ::Yamamoto::main("")
  end
end

