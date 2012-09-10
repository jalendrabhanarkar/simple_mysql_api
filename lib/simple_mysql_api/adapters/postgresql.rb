module SimpleMysqlApi
  
  class PostgreSQLAdapter
    def cast_to_string(clause)
      "CAST(#{clause} AS CHAR)"
    end
    
    def cast_as_decimal(clause)
      "CAST(#{clause} AS DECIMAL)"
    end
    
    def case_insensitive_like(clause)
      "#{clause} ilike"
    end
  end
end
