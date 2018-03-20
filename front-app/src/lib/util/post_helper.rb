require 'net/https'
require 'uri'

module Util
  module PostHelper
    def post_helper(url, content, optional_headers = {})
      headers = {
        "Content-Type": "application/json"
      }

      headers.merge(optional_headers)

      with_https_connection(url) do |uri, http|
        req = Net::HTTP::Post.new(uri.path, headers)
        req.body = content
        res = http.request(req)
        if res.code_type != Net::HTTPOK
          raise "TODO 例外クラス設定 status code: #{res.code}"
        end
        res
      end
    end

    private
    def with_https_connection(url)
      uri = url.is_a?(URI) ? url : URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)

      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      #http.set_debug_output($stderr)

      yield uri, http
    end
  end
end

