require 'json'

module Kamada
  FILE_PATH = "./ruby_backend_svc/src/kamada/files"
  FILE_NAME = "lists.txt"
  FULL_PATH = "#{FILE_PATH}/#{FILE_NAME}"

  def self.main(request_json)
    request = JSON.parse request_json

    case request["command"]
      when "create" then Kamada.create(request)
      when "list"   then Kamada.list(request)
      when "detail" then
      when "edit"   then
      when "finish" then
      when "delete" then
      else # TODO
    end
  end

  # 登録
  def self.create(request)
    title = request["options"]["title"]
    current_time = Time.now.strftime("%Y-%m-%dT%H:%M:%S+0900")

    begin
      # ファイル保存用のディレクトリが存在しなければ作成する
      Dir.mkdir(FILE_PATH) unless FileTest.exist?(FILE_PATH)

      if FileTest.exist?(FULL_PATH)
        File.open(FULL_PATH, "a+") do |f|
          id = f.readlines.length + 1
          f.puts("#{id},#{title},,,,,#{current_time}")
        end
      else
        File.open(FULL_PATH, "w") do |f|
          f.puts("1,#{title},,,,,#{current_time}")
        end
      end
      status = "ok"
      message = "承りました。"
    rescue => e
      status = "error"
      message = "登録に失敗しました。"
    end

    res = {
        status: status,
        message: message,
        created_at: current_time,
    }
    res.to_json
  end

  # 一覧取得
  def self.list(request_json)
    res = {
        list: []
    }

    if FileTest.exist?(FULL_PATH)
      File.open(FULL_PATH, "r") do |f|
        f.readlines.each do |line|
          line = line.split(",")

          res[:list] << {
              id: line[0],
              title: line[1],
              term: line[3],
              finished: !line[5].empty?,
          }
        end
      end
    end

    res.to_json
  end
end
