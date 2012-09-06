# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_mysql_api/version'
Gem::Specification.new do |gem|
  gem.name          = "simple_mysql_api"
  gem.version       = SimpleMysqlApi::VERSION
  gem.authors       = ["Jalendra Bhanarkar"]
  gem.email         = ["jbmyid@gmail.com"]
  gem.description   = "Search the records by attributes of the same table or associated tables. Search: Ex.  User.search({search_params: {name: \"Alex\", city: \"New\"}, belongs_to: false, has_many: true}) will return the User active relation with conditioning name=Alex and city=new"
  gem.summary       = "Search the records by attributes of the same table or associated tables."
  gem.homepage      = "http://jbmyid.wordpress.com"
  gem.add_dependency('rails', '>= 3.2')
  # gem.add_dependency('ActiveRecord','>= 3.2')

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end