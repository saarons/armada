# coding: UTF-8

Gem::Specification.new do |s|
  s.name        = "armada"
  s.version     = "0.1.0"
  s.authors     = ["Sam Aarons"]
  s.date        = Date.today.to_s
  s.email       = ["samaarons@gmail.com"]
  s.homepage    = "http://github.com/saarons/armada"
  s.summary     = "An ActiveModel interface to FleetDB"
  s.description = "Armada makes it simple and easy to combine ActiveModel and FleetDB together"
  
  s.rubyforge_project         = "armada"
  s.required_ruby_version     = ">= 1.9.1"
  s.required_rubygems_version = ">= 1.3.6"
  
  s.add_dependency "yajl-ruby",   ">= 0.7.4"
  s.add_dependency "activemodel", ">= 3.0.0.beta3"
  
  s.add_development_dependency "rspec", ">= 1.3.0"
 
  s.files         = Dir.glob("{lib,test}/**/*") + %w(LICENSE Rakefile README.md)
  s.require_paths = ["lib"]
end