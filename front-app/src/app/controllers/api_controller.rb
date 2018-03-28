class ApiController < ApplicationController
  def list
    #result = {
    #  list: [
    #    {
    #      id: 1,
    #      title: "xxxxxx",
    #      term: "2018-03-20T19:32:00+0900"
    #    },
    #    {
    #      id: 2,
    #      title: "yyyy",
    #      term: "2018-03-20T19:32:00+0900"
    #    }
    #  ]
    #}

    input_data = {
      command: "list",
      options: {
        condition: "all"
      }
    }

    result = XMLRPC::Client.exec_command('yamamoto', input_data.to_json)

    render json: result
  end

  def create
    #result = {
    #  status: "ok",
    #  message: "created."
    #}

    result = XMLRPC::Client.exec_command('yamamoto', params.to_json)

    render json: result
  end

  def edit
  end

  def finish
  end

  def delete
  end
end
