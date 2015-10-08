require 'resque'

module Tgp::Async
  class BaseJob
    def self.is_async_on?
      Tgp::Async::is_async_on?
    end

    def self.use_redis?
      Tgp::Async::use_redis?
    end

    def self.queue
      :async_job
    end

    def self.push(options)
      if self.is_async_on?
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
        end
      else
        self.send(:perform, options.as_json) # this makes the options a hash, which is what the perform clazzes are expecting
      end
    end

    def self.push_in(delta, options)
      if self.is_async_on? && self.use_redis?
        Resque::enqueue_in(delta, self, options)
      else
        self.push(options)
      end
    end

    def self.perform(msg)
      raise "Do something interesting here!"
    end
  end

  class AsyncJob < Tgp::Async::BaseJob
    def self.queue
      :async_job
    end

    def self.push(obj, method_name, *args)
      super(:method_name => method_name, :clazz_name => obj.class.name, :id => obj.id, :args => args)
    end

    def self.push_in(time, obj, method_name, *args)
      super(time, :method_name => method_name, :clazz_name => obj.class.name, :id => obj.id, :args => args)
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

  class PersistentAsyncJob < Tgp::Async::BaseJob
    def self.push(obj, method_name, *args)
      aq_id = AsyncQueue.create(clazz_name: obj.class.name, obj_id: obj.id, method_name: method_name, args: args.to_json, status: :queued)
      super(:aq_id => aq_id.id)
    end

    def self.perform(msg)
      puts "MESSAGE #{msg.inspect}"
      aq_id = msg["aq_id"]
      return if aq_id.nil?

      aq = AsyncQueue.queued.find(aq_id)
      return if aq.nil?

      aq.status = :started
      aq.save

      begin
        clazz = aq.clazz_name.constantize
  
        obj = clazz.find(aq.obj_id)
        args = nil
        args = JSON.parse(aq.args) if !aq.args.blank?
  
        #puts "OBJ => #{obj.inspect}"
  
        if args
          obj.send(aq.method_name, *args)
        else
          obj.send(aq.method_name)
        end

        aq.status = :completed
        aq.save

      rescue ActiveRecord::RecordNotFound => rnf
        aq.status = :failed
        aq.message = "Object #{clazz_name}/#{obj_id} is no longer available"
        aq.save

        Rails.logger.error aq.message
      rescue Exception => ex
        aq.message = "Exception => #{ex.message} => #{msg.inspect}"
        aq.status = :failed
        aq.save

        Rails.logger.error aq.message
      end
    end
  end



end
