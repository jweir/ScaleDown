# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "scale_down/version"

Gem::Specification.new do |s|
  s.name        = "scale_down"
  s.version     = ScaleDown::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John Weir"]
  s.email       = ["john@famedriver.com"]
  s.homepage    = "http://http://github.com/jweir/ScaleDown"
  s.summary     = %q{A Sinatra based server for quickly scaling and serving images. Nothing more.}
  s.description = %q{}

  s.rubyforge_project = "scale_down"

  s.add_dependency "rmagick", ">= 2.1"
  s.add_dependency "rake", ">= 0.8.7"
  s.add_dependency "sinatra", ">= 1.0"
  s.add_dependency "rmagick", ">= 2.1"
  s.add_dependency "ruby-hmac", ">= 0.4.0"

  s.add_development_dependency "contest", ">= 0.1.2"
  s.add_development_dependency "mocha", "0.9.8"
  s.add_development_dependency "rack-test", "0.5.6"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
