require_relative './basic_model'

module Yamamoto
  module Models
    class Remind < BasicModel
      @@attr = [
          :title,
          :notify_datetime,
          :term,
          :memo,
          :finished_at
      ]
    end
  end
end

