require "tgp/async/engine"
require "tgp/async/version"

module Tgp
  module Async
    def self.config(&block)
      yield Engine.config if block
      Engine.config
    end
  end
end

require "tgp/async/async_after"
