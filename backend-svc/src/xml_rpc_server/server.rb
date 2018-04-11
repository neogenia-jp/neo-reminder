#!/usr/bin/env ruby

require 'xmlrpc/server'
require 'json'

s = XMLRPC::Server.new(ENV['RPC_SERVER_PORT'], "0.0.0.0")

def _exec_command(route, input_data)
  `ROUTE=#{route} bash /mnt/route.sh <<__XXX__\n#{input_data}`
end

# 渡されたコマンドを実行し、標準出力と終了ステータスなどを返す
# @param route      [String] ルーティング文字列
# @param input_data [String] コマンドライン上に入力するコマンド
s.add_handler("exec_command") do |route, input_data|
  start_time = DateTime.now
  puts "----- #{start_time} route: #{route} -----"
  puts "#{input_data}"

  output = _exec_command route, input_data

  puts "exit_status: #{$?.inspect}"

  {
    :route => route,
    :output => output,  # TODO: 改行が欠落してしまう？
    :start_time => start_time,
    :status => $?.exitstatus,
    :finish_time => DateTime.now
  }.to_json
end

s.set_default_handler do |name, *args|
  raise XMLRPC::FaultException.new(-99, "Method #{name} missing" +
                                   " or wrong number of parameters!")
end

s.serve

