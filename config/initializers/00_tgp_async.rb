if Tgp::Async::Engine.config.tgp_async_on
  Resque.after_fork = Proc.new { 
    Resque.redis.client.reconnect
    ActiveRecord::Base.establish_connection 
  }

  if !Rails.env.development?
    uri = URI.parse(ENV[REDIS_ENV_VAR])
    puts "REDIS URI #{uri.inspect}"
    Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  end

  Rails.logger.info('Connected to Redis')
end
