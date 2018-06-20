class LocationController < ApplicationController
  def moved
    route = session['route']
    key = LocationController._build_cache_key('location', route)
    value = {
        route: route,
        lat: params[:lat],
        lng: params[:lng],
        client_time: params[:time].to_i,
        server_time: Time.now.to_i
    }

    Redis.current.set(key, value.to_json)
  end

  def self._build_cache_key(category, name)
    "#{category}/#{name}"
  end
end
