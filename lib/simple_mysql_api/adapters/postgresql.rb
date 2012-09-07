module SimpleMysqlApi
  
  class PostgreSQLAdapter
    def cast_to_string(clause)
      clause
    end
    
    def cast_as_decimal(clause)
      clause
    end
  end
end
