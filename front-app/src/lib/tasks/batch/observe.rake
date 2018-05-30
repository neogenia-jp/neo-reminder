require 'tasks/batch/batch_helper'

namespace :batch do
  namespace :observe do
    desc "監視ジョブ[経路名]"

    # バッチ起動オプション
    #   <経路名>
    batch_task :execute , [:option] do |task, args|

      # オプションに応じて企業コンテンツを取得する
      if args['option'].blank?
        raise ArgumentError.new "経路名を指定して下さい。"
      end

      route = (args['option'])

      # バッチ処理開始
      logger.info_scope("start: ObserveHandler") do
        ObserveHandler.new(route).exec
      end

    end
  end
end

