require File.expand_path("../lib/tenma_control/version", __FILE__)
require 'date'

Gem::Specification.new do |s|
    s.name    = "tenma_control"
    s.version = TenmaControl::VERSION
    s.date = Date.today.to_s
    s.summary = "Remote control protocol for Tenma/Korad power supply"
    s.author  = "Cameron Harper"
    s.email = "contact@cjh.id.au"
    s.homepage = "https://github.com/cjhdev/tenma_control"
    s.files = Dir.glob("lib/**/*.rb") + Dir.glob("test/**/*.rb") + ["rakefile"]
    s.license = 'MIT'
    s.test_files = Dir.glob("test/**/*.rb")
    s.add_development_dependency 'rake'
    s.add_development_dependency 'minitest'    
    s.add_development_dependency 'serialport'    
    s.required_ruby_version = '>= 2.0'
end
