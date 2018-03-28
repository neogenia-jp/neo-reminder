class ApiController < ApplicationController
  def list
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

    render json: result
  end

  def create
    result = {
      status: "ok",
      message: "created."
    }

    render json: result
  end

  def edit
  end

  def finish
  end

  def delete
  end
end
