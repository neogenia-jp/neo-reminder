require_relative './kamada/main'
require_relative './yamamoto/main'
require_relative './yoneoka/main'

route = ENV['ROUTE'].downcase
r = route[0]
route[0] = r.upcase

MODULE = eval route

request_json = STDIN.read

response_json = MODULE::main(request_json)

STDOUT.puts response_json

