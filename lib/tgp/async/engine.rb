module Tgp
  module Async
    class Engine < ::Rails::Engine
      config.tgp_async_on = Rails.env.production? ? true : false
      config.tgp_use_redis = true
      config.tgp_persists = false
    end
  end
end
