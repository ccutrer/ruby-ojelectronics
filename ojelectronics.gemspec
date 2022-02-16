# frozen_string_literal: true

require_relative "lib/oj_electronics/version"

Gem::Specification.new do |s|
  s.name = "ojelectronics"
  s.version = OJElectronics::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Cody Cutrer"]
  s.email = "cody@cutrer.com'"
  s.homepage = "https://github.com/ccutrer/ruby-ojelectronics"
  s.summary = "Interact with OJ Electronics/DITRA HEAT floor thermostats via MQTT"
  s.license = "MIT"
  s.metadata = {
    "rubygems_mfa_required" => "true"
  }

  s.bindir = "exe"
  s.executables = Dir["exe/*"].map { |f| File.basename(f) }
  s.files = Dir["{exe,lib}/**/*"]

  s.required_ruby_version = ">= 2.5"

  s.add_dependency "activesupport", "~> 7.0"
  s.add_dependency "faraday_middleware", "~> 1.1"
  s.add_dependency "homie-mqtt", "~> 1.6"
  s.add_dependency "net-http-persistent", "~> 4.0"

  s.add_development_dependency "byebug", "~> 9.0"
  s.add_development_dependency "rake", "~> 13.0"
  s.add_development_dependency "rubocop", "~> 1.23"
  s.add_development_dependency "rubocop-performance", "~> 1.12"
  s.add_development_dependency "rubocop-rake", "~> 0.6"
end
