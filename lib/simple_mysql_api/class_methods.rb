module SimpleMysqlApi
  module ClassMethods
    def all_belongs_to_tables
      self.reflect_on_all_associations(:belongs_to).inject({}) do |r, e|
        r[e.class_name] = {:t_name=> e.table_name, :f_key=> e.foreign_key } 
        r
      end
    end
    
    def attributes
      self.columns.inject({}) do |r,e|
        r[e.name.to_sym]= e.type.to_s
        r
      end      
    end
    
    def pri_key
      self.primary_key
    end

    def searchable_attributes
      self.attributes.delete_if{|k,v| (self.primary_key==k.to_s || self.foreign_keys.include?(k.to_s)) }
    end
    
    def search_conditions(attributes,params,properties,t_type)
      attributes.each do |attr, value|
        case(value)
          when "string","text"
            properties = text_search(attr,params,properties,t_type) if params[attr]
          when "integer","float"
            properties = range_search(attr,params,properties,t_type) if params[attr]
          when "boolean"
            properties = boolean_search(attr,params,properties,t_type) if params[attr]
        end
      end
      properties
    end
    
    def text_search(attr,params,properties,t_type)
      obj = "%#{params[attr]}%"
      properties.where(["LOWER(#{t_type.constantize.table_name}.#{attr}) like LOWER(?)",obj])
    end
    
    def range_search(attr,params,properties,t_type)
      attr_opp =  /[-,<,>]/.match(params[attr]).to_s
      table_name = "#{t_type.constantize.table_name}"
      case(attr_opp)
        when "-"
         attr_val = params[attr].split("-").inject([]){|r,e| r << e.to_f}
         properties = properties.where(["CAST(#{table_name}.#{attr} AS DECIMAL) >= ? and CAST(#{table_name}.#{attr} AS DECIMAL) <= ?",attr_val[0],attr_val[1]]) if attr_val
        when "<",">"
         attr_val = params[attr].split(attr_opp)[1].to_f
         properties = properties.where([" CAST(#{table_name}.#{attr} AS DECIMAL) #{attr_opp} ?",attr_val]) if attr_val
        else
         attr_val = params[attr].to_f
         properties = properties.where(["CAST(#{table_name}.#{attr} AS DECIMAL) = ?",attr_val]) if attr_val
       end if attr_opp
       properties
    end

    def equal_search(attr,params,properties,t_type)
      properties = properties.where(["#{t_type.constantize.table_name}.#{attr} = ?",params[attr]])
    end
    
    def boolean_search(attr,params,properties,t_type)
      val = params[attr].match(/(true|t|yes|y|1)$/i) != nil ? 1 : 0
      properties = properties.where(["CAST(#{t_type.constantize.table_name}.#{attr} AS CHAR) = ?",val.to_s])
    end
    
    def foreign_keys
      self.reflect_on_all_associations.inject([]) do |r, e|
        r << e.foreign_key
        r
      end
    end
    
    def search(params,search_params=nil)
      properties = self
      attributes = (search_params||self.attributes).delete_if{|k,v| ((self.foreign_keys.include? k.to_s)||self.primary_key==k.to_s) }
      self.all_belongs_to_tables.each do |c_name,values|
        properties = properties.joins("LEFT JOIN #{values[:t_name]} #{values[:t_name]} ON #{self.table_name}.#{values[:f_key]}=#{values[:t_name]}.#{c_name.constantize.pri_key}")
        new_attributes = c_name.constantize.searchable_attributes
        properties = search_conditions(new_attributes,params,properties,c_name)
      end
      properties = search_conditions(attributes,params,properties,self.to_s)
      properties
    end
    
  end
end