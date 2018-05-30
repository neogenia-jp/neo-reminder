require 'json'
require_relative 'api_factory'

module Kamada
  def self.main(request_json)
    # JSON解析
    json_data = JSON.parse(request_json)

    # APIクラス作成
    api = ApiFactory.get(json_data['command'])

    # 実行
    api.run(json_data).to_json
  end
end

