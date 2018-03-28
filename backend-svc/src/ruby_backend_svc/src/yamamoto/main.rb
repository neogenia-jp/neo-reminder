require 'json'

module Yamamoto
  def self.main(request_json)
    # JSON解析
    json_data = JSON.parse(request_json)

    # APIクラス作成
    api = ApiFactory.get(json_data['command'])

    # 実行
    api.run(json_data)
  end
end

