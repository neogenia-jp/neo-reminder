require 'json'
require_relative 'api_factory'

module Yoneoka
  def self.main(request_json)
    # JSON解析
    json_data = JSON.parse(request_json)

    # APIクラス作成
    api = ApiFactory.get(json_data['command'])

    result = {}

    # 実行
    begin
      result.merge!(api.run(json_data))
      result[:status] = 'ok'
    rescue => e
      result[:status] = 'error'
      result[:message] = e.message
      result[:reason] = e.message #TODO エラー内容(デバッグ用)
      result[:file] = e.backtrace #TODO file lineを正規表現で分割
      result[:line] = e.backtrace
    end

    return result.to_json
  end
end

