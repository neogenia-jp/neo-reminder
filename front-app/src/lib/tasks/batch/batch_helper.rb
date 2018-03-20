def batch_task(task_sym, arg_sym=[], &block)
  task task_sym, arg_sym => :environment do |task, args|
    include BatchLoggable
    logger_initialize
    block.call(task, args)
  end
end

module BatchLoggable
  def logger_initialize
    Rails.logger = ActiveSupport::Logger.new(STDOUT)
    Rails.logger.formatter = proc do |severity, datetime, progname, msg|
      "#{severity[0]}, [#{datetime.strftime('%Y-%m-%d %H:%M:%S.%6N')} thread:#{Thread.current.object_id.to_s(16)}]  #{severity} -- : #{msg}\n"
    end
    Rails.logger.level = Logger.const_get Rails.application.config.log_level.upcase
  end

  def logger
    Rails.logger
  end
end

