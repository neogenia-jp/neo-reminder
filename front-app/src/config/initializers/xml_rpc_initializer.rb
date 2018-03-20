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
        XMLRPC::Client.new2("http://php_alweb:#{ENV['XML_RPC_PORT']}").tap do |client|
          client.http.read_timeout = self.default_read_timeout
        end
      end

      # コマンドライン実行
      # @param command_line [String] コマンドライン
      def exec_command(command_line)
        create_default_client.call("exec_command", command_line)
      end

      # コマンドライン実行(拡張版)
      # @param command_line [String] コマンドライン
      def exec_command2(command_line)
        YAML.load create_default_client.call("exec_command2", command_line)
      end
    end
  end
end
