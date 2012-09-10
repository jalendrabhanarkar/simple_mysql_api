# SimpleMysqlApi

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'simple_mysql_api', "~> 0.0.4"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_mysql_api

## Usage

Method name: mysql_search(options={})
options:
 1. Simple search
    User.mysql_search({search_params: {name: "alex", address: "new"}})
    It will return Users having name matching alex:(mysql like "%alex%") and address matching "new"
 
 2. If model has has_many relations with other models then
    Ex. User has_many cities
    User.mysql_search({search_params: {name: "alex", city_name_: "new"}, has_many: true})
 3. If model has belongs_to relations with other model then
    Ex. Project belongs_to users
    Project.mysql_search({search_params: {name: "my_p", user_name_: "ale"}, belongs_to: true})
 
 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
