class ObserveHandler < BaseService
  attr_accessor :route

  def initialize(route)
    @route=route;
  end

  def exec(time=nil)
    # Redisよりルートごとの位置情報を取り出す
    key = LocationController._build_cache_key('location', @route)
    location = JSON.parse Redis.current.get(key)
    if location.present?
      logger.info "route=#{@route} location=[#{location['lat']}, #{location['lng']}] at #{Time.at location['client_time']}"
    else
      logger.info "route=#{@route} no location info."
    end

    input_data = {
      command: 'observe',
      options: {
        current_time: time||Time.now.iso8601,
        lat: location['lat'],  # 緯度
        long: location['lng']  # 経度
      }
    }

    # バックエンド呼び出し！
    response = _call_backend input_data

    # エラーチェック
    if response['status'] !=0
      logger.error response
      raise "バックエンドサービスが異常終了しました。ROUTE=#{@route}"
    end

    if response['output'].blank?
      logger.error response
      raise "バックエンドサービスの応答が空っぽです。ROUTE=#{@route}"
    end

    begin
      json = JSON.parse response['output']
    rescue => e
      logger.error response
      raise "バックエンドサービスの応答が正しいJSON形式ではりません。ROUTE=#{@route}"
    end

    if json['status'] != 'ok'
      raise "バックエンドサービスでエラーが発生しました。ROUTE=#{@route} message=#{json['message']}"
    end

    # 通知メール送信
    json['notifications'].each do |notification|
      body = notification['body'];
      if notification['svc_data'].present? 
        body += "\n\n#{notification['svc_data'].inspect}"
      end

      to = ENV['NOTIFY_MAIL_TO']
      #if to =~ /@gmail.com$/
      #  to = "#{$`}+#{@route}#{$&}"
      #end
      TextMailer.text_mail(
        to: to,
        from: ENV['NOTIFY_MAIL_FROM'],
        subject: "REMINDER[#{@route}] #{notification['subject']}",
        body: body
      ).deliver_now
    end
  end

  private
  def _call_backend(input_data_hash)
    route = @route
    logger.debug "route=#{route} data=#{input_data_hash}"
    XMLRPC::Client.exec_command(route, input_data_hash.to_json)
  end
end

