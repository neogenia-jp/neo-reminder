class RootController < ApplicationController
  def index
    session['route'] = _get_route
  end

  private
  def _get_route
    params['route'] || 'yamamoto'
  end

end
