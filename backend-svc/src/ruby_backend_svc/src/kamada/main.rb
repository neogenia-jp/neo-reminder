require 'json'

module Kamada
  FILE_PATH = "./ruby_backend_svc/src/kamada/files"
  FILE_NAME = "lists.txt"

  def self.main(request_json)
    request = JSON.parse request_json

    case request["command"]
      when "create" then Kamada.create(request)
      when "list"   then Kamada.list(request)
      when "detail" then
      when "edit"   then
      when "finish" then
      when "delete" then
    end
  end

  def self.create(request)
    current_time = Time.now.strftime("%Y-%m-%dT%H:%M:%S+0900")

    # ファイル保存用のディレクトリが存在しなければ作成する
    Dir.mkdir(FILE_PATH) unless FileTest.exist?(FILE_PATH)

    unless FileTest.exist?("#{FILE_PATH}/#{FILE_NAME}")
      File.open("#{FILE_PATH}/#{FILE_NAME}", "w") do |f|
        f.puts("1,#{request["options"]["title"]},#{current_time}")
      end
    else
      File.open("#{FILE_PATH}/#{FILE_NAME}", "a+") do |f|
        id = f.readlines.length + 1
        f.puts("#{id},#{request["options"]["title"]},#{current_time}")
      end
    end

    res = {
        status: "ok",
        message: "承りました。",
    }
    res.to_json
  end

  def self.list(request_json)
    res = {
        list: []
    }

    if FileTest.exist?("#{FILE_PATH}/#{FILE_NAME}")
      File.open("#{FILE_PATH}/#{FILE_NAME}", "r") do |f|
        f.readlines.each do |line|
          line = line.split(",")

          res[:list] << {
              id: line[0],
              title: line[1],
              term: line[2],
          }
        end
      end
    end

    res.to_json
  end
end
