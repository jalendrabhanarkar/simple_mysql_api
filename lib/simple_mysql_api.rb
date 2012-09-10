require "simple_mysql_api/version"
require "simple_mysql_api/class_methods.rb"
module SimpleMysqlApi
  
  # def self.connection_adapter
  #      /mysql|pg/.match(ActiveRecord::Base.configurations[Rails.env]['adapter'].downcase).to_s
  #   end
  #   
  #   # Add the class methods to the models
  #   ActiveRecord::Base.send(:include, MySqlMethods) if SimpleMysqlApi.connection_adapter=="mysql"
  #   ActiveRecord::Base.send(:include, PgMethods) if SimpleMysqlApi.connection_adapter=="pg"
end
