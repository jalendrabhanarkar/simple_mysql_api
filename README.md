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

Method name: mysql_search(options={})<br/>
options:<br/>
Simple search<br/>
    User.<b>mysql_search</b>({search_params: {name: "alex", address: "new"}})<br/>
    It will return Users having name matching alex:(mysql like "%alex%") and address matching "new"
    
Search in associated models<br/>
 1. If model has has_many relations with other models then<br/>
    Ex. User has_many cities =><br/>
    User.mysql_search({search_params: {name: "alex", city_name_: "new"}, has_many: true})<br/>
 2. If model has belongs_to relations with other model then<br/>
    Ex. Project belongs_to users =><br/>
    Project.mysql_search({search_params: {name: "my_p", user_name_: "ale"}, belongs_to: true})<br/>
 3. Search by ranges(Integer and decimals):
    Ex. If Item has price field then search for price by range
    Item.mysql_search({search_params: {price: "1000-2500"}}) # for items having price between 1000 to 2500
    Item.mysql_search({search_params: {price: "<2500"}}) # for items having price less than 2500
    <b>Operators:</b> &lt;, &gt;, &lt;= , &gt;=, - #for integer and floating attributes   
 4. Search by ranges(Datetime):
     Ex. If Item has posted_at field then search for posted_at by range
     Item.mysql_search({search_params: {posted_at: "2012-09-08 15:28:21 +0530..2012-09-10 15:27:27 +0530"}}) # for items having posted_at date between the given dates
     Item.mysql_search({search_params: {posted_at: "<2012-09-08 15:28:21 +0530"}}) # for items having posted_at date earlier than given date
     <b>Operators:</b> &lt;, &gt;, &lt;= , &gt;=, ..(for range) #for integer and floating attributes
 3. It joins the tables automatically (Please specify primary & foreign keys if you are using custom keys)<br/>
 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
