module Yamamoto
  class ApiFactory
    def self.get(command_name)
      # TODO いちいちAPIに応じて書くのめんどい
      case command_name
        when 'list'
          ListApi.new
        when 'create'
          CreateApi.new
        when 'delete'
          DeleteApi.new
        when 'detail'
          DetailApi.new
        when 'edit'
          EditApi.new
        when 'finish'
          FinishApi.new
        else
          nil
      end
    end
  end
end
