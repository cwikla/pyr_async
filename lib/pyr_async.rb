require "pyr/async/engine"
require "pyr/async/version"

require "pyr/async/async"
require "pyr/async/job"
require "pyr/async/method_missing"
require "pyr/async/after"

module Pyr
  module Async
    def self.config(&block)
      yield Engine.config if block
      Engine.config
    end
  end
end

