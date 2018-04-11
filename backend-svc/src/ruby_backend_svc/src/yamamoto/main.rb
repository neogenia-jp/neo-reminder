require 'json'

module Yamamoto
  def self.main(request_json)
    result = {
      list: [
        {
          id: 1,
          title: "xxxxxx",
          term: "2018-03-20T19:32:00+0900"
        },
        {
          id: 2,
          title: "yyyy",
          term: "2018-03-20T19:32:00+0900"
        }
      ]
    }
    result.to_json
  end
end

