require 'resque'

module Tgp::Async
  def self.is_async_on?
    Tgp::Async::Engine.config.tgp_async_on
  end

  def self.persist?
    Tgp::Async::Engine.config.tgp_persists
  end

  def self.use_redis?
    Tgp::Async::Engine.config.tgp_use_redis
  end

end
