class HelloController < ApplicationController
  def hello
    @msg = "world!"
    if (session[:count])
      session[:count] += 1
    else
      session[:count] = 1
    end
  end
end
