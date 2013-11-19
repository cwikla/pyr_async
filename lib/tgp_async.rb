require "tgp/async/engine"
require "tgp/async/version"

require "tgp/async/async"
require "tgp/async/job"
require "tgp/async/method_missing"
require "tgp/async/after"

module Tgp
  module Async
    def self.config(&block)
      yield Engine.config if block
      Engine.config
    end
  end
end

