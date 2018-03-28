module Yamamoto
  class BaseApi
    def initialize
      @data_accessor = DataAccessor.new
    end

    def run(json_string)
      raise NotImplementedError "サブクラスで実装してください。"
    end
  end
end

