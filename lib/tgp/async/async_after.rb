require 'resque'

module Tgp::Async
  def self.async_on?
    Tgp::Async::Engine.config.tgp_async_on
  end

  module MethodMissing
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
    end

    def tgp_async_method_push_job(obj, method_name, *args)
      Tgp::Async::AfterAsyncJob.push(self, method_name, *args)
    end

    def method_missing(method_name, *args, &block)
      if method_name =~ /_async$/
        orig = method_name.to_s.split(/_async$/)[0]
        if self.respond_to? orig # this is our method
          return tgp_async_method_push_job(self, orig, *args)
        end
      end

      super
    end

  end

  class Job
    def self.use_redis?
      @@async_on ||= Tgp::Async::Engine.config.tgp_async_on
    end

    def self.queue
      :async_job
    end

    def self.push(options)
      if self.use_redis?
        #puts "PUSHING THROUGH REDIS"
        Resque.enqueue(self, options)

=begin
        This code was added initially when Audity was having trouble,
        but may have been fixed when Cwikla took over HireFire
        if ::Resque::Job.workers <= 1 # hack
          ::Resque::Job.environment.hire
        end
=end

      else
        self.send(:perform, options.as_json) # this makes the options a hash, which is what the perform clazzes are expecting
      end
    end

    def self.perform(msg)
      raise "Do something interesting here!"
    end

  end

  class AfterAsyncJob < Tgp::Async::Job
    def self.queue
      :after_async_job
    end

    def self.push(obj, method_name, *args)
      super(:method_name => method_name, :clazz_name => obj.class.name, :id => obj.id, :args => args)
    end

    def self.perform(msg)
      Rails.logger.debug "MSG => #{msg.inspect}"

      method_name = msg["method_name"]
      clazz_name = msg["clazz_name"]
      record_id = msg["id"]
      args = msg["args"]

      if method_name.nil? || clazz_name.nil? || record_id.nil?
        Rails.logger.debug "Missing method_name" if method_name.nil?
        Rails.logger.debug "Missing clazz_name" if clazz_name.nil?
        Rails.logger.debug "Missing record_id" if record_id.nil?
        # no need to check for args
        return
      end

      clazz = clazz_name.constantize

      if clazz.nil?
        Rails.logger.error "Unable to find class #{clazz_name}"
        return
      end

      #puts "METHOD NAME #{method_name} #{args}"

      begin
        obj = clazz.find(record_id)
        #puts "OBJ => #{obj.inspect}"
        if args
          obj.send(method_name, *args)
        else
          obj.send(method_name)
        end

      rescue ActiveRecord::RecordNotFound => rnf
        Rails.logger.error "Object #{clazz_name}/#{record_id} is no longer available"
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
