require 'resque'

module TgpAsync
  class AsyncJob
    def self.use_redis?
      @@async_on ||= TgpAsync::Engine.config.tgp_async_on
    end

    def self.queue
      :async_job
    end

    def self.push(options)
      if self.use_redis?
        puts "PUSHING THROUGH REDIS"
        Resque.enqueue(self, options)

        if ::Resque::Job.workers <= 1 # hack
          ::Resque::Job.environment.hire
        end

      else
        self.send(:perform, options.as_json) # this makes the options a hash, which is what the perform clazzes are expecting
      end
    end

    def self.perform(msg)
      raise "Do something interesting here!"
    end

  end

  class AfterAsyncJob < AsyncJob
    def self.queue
      :after_async_job
    end

    def self.push(obj, method_name)
      super(:method_name => method_name, :clazz_name => obj.class.name, :id => obj.id)
    end

    def self.perform(msg)
      puts msg.inspect

      method_name = msg["method_name"]
      clazz_name = msg["clazz_name"]
      record_id = msg["id"]

      if method_name.nil? || clazz_name.nil? || record_id.nil?
        puts "Missing method_name" if method_name.nil?
        puts "Missing clazz_name" if clazz_name.nil?
        puts "Missing record_id" if record_id.nil?
        return
      end

      clazz = Kernel.const_get(clazz_name)

      if clazz.nil?
        puts "Unable to find class #{clazz_name}"
        return
      end

      begin
        obj = clazz.find(record_id)
        obj.send(method_name)

      rescue ActiveRecord::RecordNotFound => rnf
        puts "Object #{clazz_name}/#{record_id} is no longer available"
      end
    end
  end


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
        AfterAsyncJob.push(self, m)
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
