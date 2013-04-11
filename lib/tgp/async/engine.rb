module Tgp
  module Async
    class Engine < ::Rails::Engine
      config.tgp_async_on = false
    end
  end
end
