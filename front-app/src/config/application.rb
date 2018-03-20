require File.expand_path('../boot', __FILE__)

# require 'rails/all'
%w(
  action_controller
  action_view
  action_mailer
  active_job
  rails/test_unit
  sprockets
).each do |framework|
  begin
    require "#{framework}/railtie"
  rescue LoadError
  end
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.time_zone = 'Tokyo'
    #config.active_record.default_timezone = :utc

    ## 日本語化
    # I18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ja

    # modelの階層化
    config.autoload_paths += Dir[Rails.root.join('app/models/**/')]

    # custom validators path
    config.autoload_paths += Dir[Rails.root.join('app/validators')]

    # lib以下をload pathに追加
    config.autoload_paths += Dir[Rails.root.join("lib")]
    # プロダクションの場合eager_loadになるが、その際になぜかlibが追加されていなかったので追加
    config.eager_load_paths += Dir[Rails.root.join("lib")]

    # Active Jobのアダプタ設定
    config.active_job.queue_adapter = :delayed_job

    # redis setting
    config.session_store :redis_store, servers: "redis://#{ENV['REDIS_HOST']}:6379/0", expire_in: 1.day
  end
end
