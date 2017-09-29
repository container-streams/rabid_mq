# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rabid_mq/version'

Gem::Specification.new do |spec|
  spec.name          = "rabid_mq"
  spec.version       = RabidMQ::VERSION
  spec.authors       = ["Tyrone Wilson"]
  spec.email         = ["tyrone.wilson@blackswan.com"]

  spec.summary       = %q{Provides easy way to configure and use RabbitMQ in Ruby on Rails}
  spec.description   = %q{If you want to just get up and going in making your rails app into a producer or consumer of RabbitMQ events then use this gem}
  spec.homepage      = "https://github.com/container-streams/rabid_mq"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'bunny', '~> 2.7.1'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 11.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "hashie"
end
