Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.action_mailer.perform_caching = false

    config.cache_store = :redis_store, "redis://#{ENV['REDIS_HOST']}:6379/0"
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.action_mailer.perform_caching = false

    config.cache_store = :null_store
  end

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  #開発用メール送信設定(http://$(docker-host-ip):1080で確認出来る)
  config.action_mailer.smtp_settings = {
    :address => 'mocksmtp',
    :port => '1025',
  }
  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  #config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  #
  # docker-machineのshared_folderでホストとファイル共有している場合ファイルが変更されても
  # 自動検出されないのでEventedでなくpolling方式のFileUpdateCheckerでwatchするようにする
  # この際、docker-machineとローカルの日付がずれているとうまくファイルの変更を検知してくれない場合があるため、
  # ずれいている場合はdocker-machine ssh でゲストOSに入り
  #  sudo VBoxControl guestproperty set "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold" 5000
  # でホストとの時刻の差のしきい値を下げる(ここでは５秒)
  # virtual box以外の場合は別途調査
  #config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  config.file_watcher = ActiveSupport::FileUpdateChecker

  #web-console setting
  config.web_console.whitelisted_ips = %w( 0.0.0.0/0 ::/0 )

  #devise
  #TODO 動的に設定できるようにできたらする
  config.action_mailer.default_url_options = { 
    host: '192.168.99.100'
  }

end
