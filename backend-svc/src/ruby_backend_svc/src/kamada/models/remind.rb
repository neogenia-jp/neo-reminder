require_relative './base_model'

module Kamada
  class Remind < BaseModel
    define_attributes(
        :id,
        :title,
        :notify_datetime,
        :term,
        :memo,
        :finished_at,
        :created_at
    )
  end
end
