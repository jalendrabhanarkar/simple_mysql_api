class << ActiveRecord::Base
  def has_simple_mysql_api
    extend SimpleMysqlApi::ClassMethods
  end
end