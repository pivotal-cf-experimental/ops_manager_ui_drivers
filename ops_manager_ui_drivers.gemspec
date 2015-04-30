# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ops_manager_ui_drivers/version'

Gem::Specification.new do |spec|
  spec.name          = 'ops_manager_ui_drivers'
  spec.version       = OpsManagerUiDrivers::VERSION
  spec.authors      = ['Pivotal, Inc.']
  spec.email        = ['cf-tempest-eng+ops_manager_ui_drivers@pivotal.io']

  spec.summary       = %q{Capybara helpers for configuring Pivotal Ops Manager}
  spec.homepage      = 'https://github.com/pivotal-cf-experimental/ops_manager_ui_drivers'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'capybara'
  spec.add_dependency 'capybara-webkit'
  spec.add_dependency 'selenium-webdriver'

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rspec'
end
