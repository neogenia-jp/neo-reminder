module Yamamoto
  class ApiFactory
    def self.get(command_name)
      require_relative "./#{command_name}_api"
      Yamamoto.const_get("#{command_name.capitalize}Api").new
    end
  end
end
