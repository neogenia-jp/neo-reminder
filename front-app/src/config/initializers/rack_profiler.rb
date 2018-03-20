#環境変数にPROFILEが定義されていてかつdevelopmentの場合のみプロファイラ起動
if ENV["PROFILE"] == "1" && Rails.env == 'development'
  require 'rack-mini-profiler'

  # initialization is skipped so trigger it
  Rack::MiniProfiler.config.base_url_path = "/mini-profiler-resources/"
  Rack::MiniProfilerRails.initialize!(Rails.application)
end

