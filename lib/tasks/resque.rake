require 'resque/tasks'

task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'
  Resque.before_fork do
    defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!
  end

  Resque.after_fork = Proc.new { 
    Resque.redis.client.reconnect
    ActiveRecord::Base.establish_connection 
  }
end

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"

desc "Get rid of hanging workers"
task "resque:reset" => :environment do
  ENV['QUEUE'] = '*'
  Resque.workers.each { |w|
  #  w.prune_dead_workers
    w.unregister_worker
  }
end

desc "Delete all resque jobs"
task "resque:clear" => :environment do
  Resque.redis.del "queue:*"
end
