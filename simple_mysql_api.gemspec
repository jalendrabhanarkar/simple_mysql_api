# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_mysql_api/version'
Gem::Specification.new do |gem|
  gem.name          = "simple_mysql_api"
  gem.version       = SimpleMysqlApi::VERSION
  gem.authors       = ["jalendrabhanarkar"]
  gem.email         = ["jalendra@sapnasolutions.com"]
  gem.description   = "Used for basic api operations,like searching etc."
  gem.summary       = "First gem to check the functionality."
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
