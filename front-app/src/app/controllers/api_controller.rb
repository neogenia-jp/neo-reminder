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

    result = _call_backend input_data

    render json: result
  end

  def create
    #result = {
    #  status: "ok",
    #  message: "created."
    #}

    result = _call_backend params

    render json: result
  end

  def edit
  end

  def finish
  end

  def delete
  end

  private
  def _call_backend(input_data_hash)
    route = session['route']
    logger.debug "route=#{route} data=#{input_data_hash}"
    XMLRPC::Client.exec_command(route, input_data_hash.to_json)
  end
end
