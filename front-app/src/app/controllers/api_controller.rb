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

  def detail
    input_data = {
      command: "detail",
      options: {
        id: params[:id]
      }
    }

    result = _call_backend input_data
    #result = {
    #  output: {
    #    id: 1,
    #    title: 'テスト',
    #    notify_datetime: '2018-03-29T19:32:00+0900',
    #    term: '2018-03-29T19:32:00+0900',
    #    created_at: '2018-03-29T19:32:00+0900',
    #    finished_at: '2018-03-29T19:32:00+0900',
    #    memo: 'めもめお'
    #  }.to_json
    #}
    render json: result
  end

  def edit
    input_data = {
      command: "edit",
      options: {
        id: params['id'],
        title: params['title'],
        notify_datetime: params['notify_datetime'],
        term: params['term'],
        memo: params['memo']
      }
    }

    result = _call_backend input_data
    #result = {
    #  output: {
    #    status: 'ok',
    #    created_at: '2018-03-29T19:32:00+0900',
    #  }.to_json
    #}
    render json: result
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
