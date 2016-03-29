module Pyr
  module Async
    class Engine < ::Rails::Engine
      config.pyr_async_on = Rails.env.production? ? true : false
      config.pyr_use_redis = true
      config.pyr_persists = false
    end
  end
end
