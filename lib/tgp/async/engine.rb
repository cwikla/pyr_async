module Tgp
  module Async
    class Engine < ::Rails::Engine
      config.tgp_async_on = true
      config.tgp_use_redis = true
      config.tgp_persists = true
    end
  end
end
