require 'redis'
Redis.current = Redis.new(
    host: ENV['REDIS_HOST'],
    port: 6379,
    db: 1
)
