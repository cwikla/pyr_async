require 'resque'

module Pyr::Async
  def self.is_async_on?
    Pyr::Async::Engine.config.pyr_async_on
  end

  def self.persist?
    Pyr::Async::Engine.config.pyr_persists
  end

  def self.use_redis?
    Pyr::Async::Engine.config.pyr_use_redis
  end

  def self.queues
    (Pyr::Async::Engine.config.pyr_async_queues || []) + [ :async_queue ]
  end

end
