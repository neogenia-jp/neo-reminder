require 'xmlrpc/client'

module XMLRPC
  class Client
    class << self
      # デフォルトのHTTP応答タイムアウトを設定する（秒）
      def default_read_timeout=(val)
        @@default_read_timeout = val
      end

      # デフォルトのHTTP応答タイムアウト（秒）
      # デフォルトは 3600秒
      def default_read_timeout
        @@default_read_timeout ||= 3600
      end

      # デフォルト設定が行われた xml_rpc client を生成します
      def create_default_client
        XMLRPC::Client.new2("http://backend_svc:#{ENV['RPC_SERVER_PORT']}").tap do |client|
          client.http.read_timeout = self.default_read_timeout
        end
      end

      # コマンドライン実行
      # @param route      [String] ルーティング文字列
      # @param input_data [String] 受け渡す入力データ
      def exec_command(route, input_data)
        result = JSON.parse create_default_client.call("exec_command", route, input_data)
        logger.debug result
        result
      end
    end
  end
end
