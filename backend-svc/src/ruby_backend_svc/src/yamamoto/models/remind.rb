require_relative './base'

module Yamamoto
  module Models
    class Remind < Base
      @@model_dir_name = 'reminds'
      @@attributes = [
          :title,
          :notify_datetime,
          :term,
          :memo,
          :finished_at
      ]
      attr_accessor *@@attributes

      def initialize(contents=nil)
        super(@@attributes, contents)
      end
    end
  end
end

