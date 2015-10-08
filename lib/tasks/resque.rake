require 'resque/tasks'
require 'resque/scheduler/tasks'

namespace :resque do
  task :setup => :environment do
    ENV['QUEUES'] = '*'
    Resque.before_fork do
      defined?(ActiveRecord::Base) and
        ActiveRecord::Base.connection.disconnect!
    end
  
    Resque.after_fork = Proc.new { 
      Resque.redis.client.reconnect
      ActiveRecord::Base.establish_connection 
    }
  end

  task :setup_scheduler => :setup do
    require 'resque-scheduler'
    Resque.schedule = {}
  end
end

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => :environment do
  Dir[File.join(Rails.root, 'app/jobs/**/*.rb')].each do |path|
    require path
  end
  all_async_queues = Tgp::Async::BaseJob.descendants.map(&:queue).uniq.join(',')
  ENV['QUEUES'] = all_async_queues

  Rake::Task["resque:work"].invoke
end

desc "Alias for the delayed resque:work (To run the delayed worker on Heroku)"
task "jobs:scheduler" => "resque:scheduler"

desc "Get rid of hanging workers"
task "resque:reset" => :environment do
  ENV['QUEUES'] = '*'
  Resque.workers.each { |w|
  #  w.prune_dead_workers
    w.unregister_worker
  }
end

desc "Delete all resque jobs"
task "resque:clear" => :environment do
  Resque.redis.del "queue:*"
end
