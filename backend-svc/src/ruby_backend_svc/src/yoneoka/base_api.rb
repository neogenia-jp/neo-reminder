require_relative 'data_accessor'

module Yoneoka
  class BaseApi
    def initialize
      @data_accessor = DataAccessor.instance
    end

    def run(json_data)
      raise NotImplementedError "サブクラスで実装してください。"
    end
  end
end

