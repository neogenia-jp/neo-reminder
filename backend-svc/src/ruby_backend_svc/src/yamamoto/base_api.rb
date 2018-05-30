require_relative 'data_accessor'

module Yamamoto
  class BaseApi
    def initialize
      @data_accessor = DataAccessor.new
    end

    def run(json_data)
      raise NotImplementedError "サブクラスで実装してください。"
    end
  end
end

