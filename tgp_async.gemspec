$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tgp/async/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tgp_async"
  s.version     = Tgp::Async::VERSION
  s.authors     = ["The Giant Pixel"]
  s.email       = ["code@thegiantpixel.com"]
  s.homepage    = "http://code.thegiantpixel.com"
  s.summary     = "TGP Async Library for doing background jobs with Redis"
  s.description = "TGP Async Library for doing background jobs with Redis"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"
end
