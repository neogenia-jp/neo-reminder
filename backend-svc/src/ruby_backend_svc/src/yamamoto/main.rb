require 'json'
Dir[File.dirname(__FILE__) + '/*.rb'].each {|file| require file }

module Yamamoto
  def self.main(request_json)
    # JSON解析
    json_data = JSON.parse(request_json)

    # APIクラス作成
    api = ApiFactory.get(json_data['command'])

    # 実行
    api.run(json_data).to_json
  end
end

