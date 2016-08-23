Resque.logger = Logger.new(File.open("#{Rails.root}/log/resque.log", "w+"))
Resque.logger.formatter = Resque::QuietFormatter.new
