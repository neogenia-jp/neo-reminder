module Yamamoto
  class ApiFactory
    def self.get(command_name)
      case command_name
        when 'list'
          ListApi.new
        when 'create'
          CreateApi.new
        else
          nil
      end
    end
  end
end
