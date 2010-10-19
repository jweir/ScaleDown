# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "scale_down/version"

Gem::Specification.new do |s|
  s.name        = "scale_down"
  s.version     = ScaleDown::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John Weir"]
  s.email       = ["john@famedriver.com"]
  s.homepage    = "http://rubygems.org/gems/scale_down"
  s.summary     = %q{A Sinatra based server for quickly scaling and serving images.}
  s.description = %q{}

  s.rubyforge_project = "scale_down"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
