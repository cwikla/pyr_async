
if TgpAsync::Engine.config.tgp_async_on
  if defined?(HireFire)
    Rails.logger.info("Configuring HireFire")

    MAX_HIREFIRE_WORKERS = Rails.env.production? ? (ENV['MAX_HIREFIRE_WORKERS'] || 9).to_i : 1

    puts "MAX_HIREFIRE_WORKERS WILL BE #{MAX_HIREFIRE_WORKERS}"

    HireFire.configure do |config|
      config.environment      = Rails.env.production? ? :heroku : :local
      config.max_workers      = MAX_HIREFIRE_WORKERS
      config.min_workers      = 0   # default is 0
      config.app_name         = TGP_HEROKU_APP_NAME
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
end
