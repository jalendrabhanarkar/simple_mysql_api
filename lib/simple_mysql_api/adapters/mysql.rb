module SimpleMysqlApi
  
  #To add the class methods to Models
  class MysqlAdapter
    def cast_to_string(clause)
      "CAST(#{clause} AS CHAR)"
    end
    
    def cast_as_decimal(clause)
      "CAST(#{clause} AS DECIMAL)"
    end
    
    def case_insensitive_like(clause)
      "LOWER(#{clause}) like"
    end
    
    def cast_to_datetime(clause)
      "UNIX_TIMESTAMP(#{clause})"
    end
  end
end
