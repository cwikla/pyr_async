module Pyr
  module Async

    class AsyncQueue < ActiveRecord::Base
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
