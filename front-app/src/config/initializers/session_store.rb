# Be sure to restart your server when you modify this file.
# 個別にsession storeを定義するためここはコメント
# Rails.application.config.session_store :cookie_store, key: '_app_session'

#class Redis
#  class Store < self
#    module Marshalling
#      alias __marshal _marshal
#      alias __unmarshal _unmarshal
#
#      private
#      def _marshal(val, options, &block)
#        # HACK: Hashの場合は PHP とのセッションデータ共有のためにもJSON形式を使う
#        if val.is_a?(Hash)
#          yield marshal?(options) ? val.to_json : val
#        else
#          # original を呼ぶ
#          __marshal(val, options, &block)
#        end
#      end
#
#      def _unmarshal(val, options, &block)
#        if val.is_a?(String) && %w/{ [/.include?(val.unpack('c1')[0].chr)
#          unmarshal?(val, options) ? JSON.parse(val) : val
#        else
#          # original を呼ぶ
#          __unmarshal(val, options, &block)
#        end
#      end
#    end
#  end
#end
