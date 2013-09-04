# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "libnotify/version"

Gem::Specification.new do |s|
  s.name        = "libnotify"
  s.version     = Libnotify::VERSION
  s.authors     = ["Peter Suschlik"]
  s.email       = ["peter-libnotify@suschlik.de"]
  s.homepage    = "http://rubygems.org/gems/libnotify"
  s.summary     = %q{Ruby bindings for libnotify using FFI}
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'ffi', '>= 1.0.11'

  s.add_development_dependency 'yard', '~> 0.8.6.1'
  s.add_development_dependency 'minitest', '~> 4.7.4'
  s.add_development_dependency 'minitest-libnotify', '~> 0.2.2'
  s.add_development_dependency 'simplecov'
end
