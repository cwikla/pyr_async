$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "pyr/async/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "pyr_async"
  s.version     = Pyr::Async::VERSION
  s.authors     = ["John Cwikla"]
  s.email       = ["pyr@cwikla.com"]
  s.homepage    = "http://pyr.cwikla.com"
  s.summary     = "Pyr Async Library for doing background jobs with Redis"
  s.description = "Pyr Async Library for doing background jobs with Redis Description"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 5.0.2"
  s.add_dependency "resque"
  s.add_dependency "resque-scheduler"
end
