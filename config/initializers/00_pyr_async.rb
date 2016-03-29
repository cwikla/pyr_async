REDIS_ENV_VAR = "REDISTOGO_URL"

if Pyr::Async::Engine.config.pyr_async_on
  Resque.after_fork = Proc.new { 
    Resque.redis.client.reconnect
    ActiveRecord::Base.establish_connection 
  }

  if ENV[REDIS_ENV_VAR]
    uri = URI.parse(ENV[REDIS_ENV_VAR])
    puts "REDIS URI #{uri.inspect}"
    Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  end

  Rails.logger.info('Connected to Redis')
end
