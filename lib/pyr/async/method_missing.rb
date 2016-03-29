require 'resque'

module Pyr::Async
  module MethodMissing
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
    end

    def pyr_async_method_push_job(obj, method_name, *args)
      if Pyr::Async::persist?
        Pyr::Async::PersistentAsyncJob.push(self, method_name, *args)
      else
        Pyr::Async::AsyncJob.push(self, method_name, *args)
      end
    end

    def method_missing(method_name, *args, &block)
      if method_name =~ /_async$/
        orig = method_name.to_s.split(/_async$/)[0]
        if self.respond_to? orig # this is our method
          return pyr_async_method_push_job(self, orig, *args)
        end
      end

      super
    end

  end
end
