require "tgp_async/engine"

module TgpAsync
  def self.config(&block)
    yield Engine.config if block
    Engine.config
  end
end

require "tgp_async/async_job"
