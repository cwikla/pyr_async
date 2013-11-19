require 'resque'

module Tgp::Async
  module AsyncAfter
    extend ActiveSupport::Concern

    included do
      after_create    :create_after_async_callbacks
      after_save      :save_after_async_callbacks
      after_destroy   :destroy_after_async_callbacks
    end

    module ClassMethods
      def async_callbacks
        @@the_async_callbacks ||= {}
      end

      def async_add_after(cb_sym, *methods)
        async_callbacks[cb_sym] ||= []
        async_callbacks[cb_sym] += methods
      end

      def async_after_create(*methods)
        async_add_after(:create, *methods)
      end

      def async_after_save(*methods)
        async_add_after(:save, *methods)
      end

      def async_after_destroy(*methods)
        async_add_after(:destroy, *methods)
      end
    end

    protected

    def do_callbacks(method)
      methods = self.class.async_callbacks[method]
      return if methods.nil?

      methods.each do |m|
        AsyncJob.push(self, m)
      end

    end

    def create_after_async_callbacks
      do_callbacks(:create)
    end

    def save_after_async_callbacks
      do_callbacks(:save)
    end

    def destroy_after_async_callbacks
      do_callbacks(:destroy)
    end

  end
end
