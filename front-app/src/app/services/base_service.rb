class BaseService
  def logger
    Rails.logger
  end


  def with_transaction
    ActiveRecord::Base.transaction do
      yield
    end
  end
end

