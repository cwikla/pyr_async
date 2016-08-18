if ENV['USE_HIRE_FIRE'] && defined?(HireFire)
  Rails.logger.info("Configuring HireFire")

  MAX_HIREFIRE_WORKERS = Rails.env.production? ? (ENV['MAX_HIREFIRE_WORKERS'] || 9).to_i : 1

  min_workers = defined?(MIN_HIREFIRE_WORKERS) ? MIN_HIREFIRE_WORKERS : 0
  puts "MAX_HIREFIRE_WORKERS WILL BE #{MAX_HIREFIRE_WORKERS}"
  puts "MIN_HIREFIRE_WORKERS WILL BE #{min_workers}"

  HireFire.configure do |config|
    config.environment      = Rails.env.development? ? :local : :heroku
    config.max_workers      = MAX_HIREFIRE_WORKERS
    config.min_workers      = min_workers
    config.app_name         = PYR_HEROKU_APP_NAME
    config.job_worker_ratio = [
        { :jobs => 1,   :workers => [1, 1].max },
        { :jobs => 20,  :workers => [config.max_workers / 5, 1].max },
        { :jobs => 40,  :workers => [config.max_workers / 4, 1].max },
        { :jobs => 60,  :workers => [config.max_workers / 3, 1].max },
        { :jobs => 80,  :workers => [config.max_workers / 2, 1].max },
        { :jobs => 100,  :workers => [config.max_workers / 1, 1].max }
      ]
  end
end
