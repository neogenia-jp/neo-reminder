require 'json'
require 'time'

module Yoneoka
  def self.main(request_json)

    @@data_filepath = File.expand_path("../yoneoka.json", __FILE__)

    read_data_json
    command = JSON.parse(request_json)["command"]
    options = JSON.parse(request_json)["options"]

    if command == "list"
      list options["condition"]
    elsif command == "detail"
      detail options["id"]
    elsif command == "create"
      create options["title"]
    elsif command == "edit"
      # edit options
    elsif command == "delete"
      # delete options["id"]
    elsif command == "finish"
      # finish options["id"]
    end

  end

  def self.read_data_json
    if !File.exist?(@@data_filepath)
      File.open(@@data_filepath, "w") do |file|
        file.puts "[]"
      end
    end

    @@hash = File.open(@@data_filepath) do |file|
      JSON.load(file)
    end
  end

  def self.write(hash)
    begin
      File.open(@@data_filepath, 'w') do |io|
        io.puts(JSON.pretty_generate(hash))
        true
      end
    rescue Exception => e
      false
    end
  end

  def self.list (condition)
    # todo condition all/today/undefined
    # todo finished
    result = {list: @@hash}
    result.to_json
  end

  def self.detail(id)
    result = {detail: @@hash.select {|item| item["id"] == id}}
    result.to_json
  end

  def self.create(title)
    # idの最大値を取得
    max_id = 0
    @@hash.each do |item|
      max_id = [max_id, item["id"]].max
    end

    newitem = {
        "id" => max_id + 1,
        "title" => title,
        "created_at" => Time.new.iso8601,
    }

    @@hash = @@hash.push(newitem)
    is_success = write(@@hash)
    # todo messageって何を出す？
    result = {create: {status: (is_success ? "ok" : "error"), message: is_success}}
    result.to_json
  end

end

