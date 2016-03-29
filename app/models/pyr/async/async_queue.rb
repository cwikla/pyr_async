module Pyr
  module Async

    class AsyncQueue < ActiveRecord::Base
      attr_accessible :deleted_at,
        :queued_at,
        :started_at,
        :completed_at,
        :failed_at,
        :status,
        :clazz_name,
        :obj_id,
        :method_name,
        :args
    
      before_save :check_ts_fields
    
      def check_ts_fields
        self.status = :queued if self.status.nil?
    
        if self.status_changed?
          self.send("#{self.status}_at=", Time.zone.now)
        end
      end

      def self.queued
        where(:status => :queued)
      end

      def self.started
        where(:status => :started)
      end

      def self.running
        started
      end

      def self.failed
        where(:status => :failed)
      end

      def self.completed
        where(:status => :completed)
      end
    end
  end
end
