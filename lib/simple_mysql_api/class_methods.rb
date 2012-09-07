module SimpleMysqlApi
  
  #To add the class methods to Models
  module SimpleMysqlApiMethods
    
    #Class methods for modles
    module ClassMethods
      
      # Returns the asscociated models with their table name, class name, forignkey
      # eg. User.tables_by_relation(:has_many)
      # returns {"City"=>{:t_name=>"cities", :f_key=>"user_id"}} 
      def tables_by_relation(rel)
        self.reflect_on_all_associations(rel).inject({}) do |r, e|
          r[e.class_name] = {:t_name=> e.table_name, :f_key=> e.foreign_key } 
          r
        end
      end

      # Returns the hash of attributes of the table and their type
      # eg. User.attributes
      # returns [{:attr=>"id", :type=>"integer", :param_name=>:id}, {:attr=>"name", :type=>"string", :param_name=>:name}]
      def attributes(c_name=nil)
        self.columns.inject([]) do |r,e|
          r << {:attr=>e.name, :type=>e.type.to_s, :param_name => (c_name ? (c_name.downcase+ "_" + e.name) : e.name).to_sym }
          r
        end      
      end
      
      # Returns the primary key
      def pri_key
        self.primary_key
      end

      # returns all the attributes except primary keys and foreign keys
      def searchable_attributes(c_name=nil)
        self.attributes(c_name).delete_if{|v| (self.primary_key==v[:attr].to_s || self.foreign_keys.include?(v[:attr].to_s)) }
      end
      
      # Adds the conditions for the attributes passed based on the attributes type
      def search_conditions(attributes,params,act_relation,t_type)
        attributes.each do |value|
          case(value[:type])
            when "string","text"
              act_relation = text_search(value,params,act_relation,t_type) 
            when "integer","float"
              act_relation = range_search(value,params,act_relation,t_type)
            when "datetime"
              act_relation = date_search(value,params,act_relation,t_type)
            when "boolean"
              act_relation = boolean_search(value,params,act_relation,t_type)
          end if params[value[:param_name]]
        end
        act_relation
      end
      
      # for the text search if it contains the string
      def text_search(attr,params,act_relation,t_type)
        obj = "%#{params[attr[:param_name]]}%"
        act_relation.where(["LOWER(#{t_type.constantize.table_name}.#{attr[:attr]}) like LOWER(?)",obj])
      end

      # for the integer, float attributes 
      # eg. price="12"
      # price="12-100"
      # price="<100"
      # price=">100"
      def range_search(attr,params,act_relation,t_type)
        attr_opp =  /[-,<,>]/.match(params[attr[:param_name]]).to_s + /[=]/.match(params[attr[:param_name]]).to_s
        table_name = "#{t_type.constantize.table_name}" 
        case(attr_opp)
          when "-"
           attr_val = params[attr[:param_name]].split("-").inject([]){|r,e| r << e.to_f}
           act_relation = act_relation.where(["CAST(#{table_name}.#{attr[:attr]} AS DECIMAL) >= ? and CAST(#{table_name}.#{attr[:attr]} AS DECIMAL) <= ?",attr_val[0],attr_val[1]]) if attr_val
          when "<",">","<=",">="
           attr_val = params[attr[:param_name]].split(attr_opp)[1].to_f
           act_relation = act_relation.where([" CAST(#{table_name}.#{attr[:attr]} AS DECIMAL) #{attr_opp} ?",attr_val]) if attr_val
          else
           attr_val = params[attr[:param_name]].to_f
           act_relation = act_relation.where(["CAST(#{table_name}.#{attr[:attr]} AS DECIMAL) = ?",attr_val]) if attr_val
         end if attr_opp
         act_relation
      end
      
      # for the datetime
      # eg. created_at ="2012-08-28 16:21:37 +0530"
      # created_at = "2012-08-28 16:21:37 +0530..2012-09-28 16:21:37 +0530""
      # created_at="<2012-08-28 16:21:37 +0530"
      # created_at=">2012-08-28 16:21:37 +0530"
      def date_search(attr,params,act_relation,t_type)
        attr_opp =  /[<,>]/.match(params[attr[:param_name]]).to_s + /[=]/.match(params[attr[:param_name]]).to_s
        attr_opp = params[attr[:param_name]].index("..") ? ".." : attr_opp
        table_name = "#{t_type.constantize.table_name}" 
        case(attr_opp)
          when ".."
            attr_val = params[attr[:param_name]].split("..").inject([]){|r,e| r << e}
            act_relation = act_relation.where(["#{table_name}.#{attr[:attr]} >= ? and #{table_name}.#{attr[:attr]} <= ?",attr_val[0],attr_val[1]]) if attr_val
          when "<",">","<=",">="
            attr_val = params[attr[:param_name]].split(attr_opp)[1]
            act_relation = act_relation.where(["#{table_name}.#{attr[:attr]} #{attr_opp} ?",attr_val]) if attr_val
          else
            attr_val = params[attr[:param_name]].split(attr_opp)[1]
            act_relation = act_relation.where(["#{table_name}.#{attr[:attr]} = ?",attr_val]) if attr_val
         end if attr_opp
         act_relation
      end

      # for any type
      # eg. price="12"
      def equal_search(attr,params,act_relation,t_type)
        act_relation = act_relation.where(["#{t_type.constantize.table_name}.#{attr[:attr]} = ?",params[attr[:param_name]]])
      end

      # for boolean type
      # eg. price="true"
      def boolean_search(attr,params,act_relation,t_type)
        val = params[attr[:param_name]].match(/(true|t|yes|y|1)$/i) != nil ? 1 : 0
        act_relation = act_relation.where(["CAST(#{t_type.constantize.table_name}.#{attr[:attr]} AS CHAR) = ?",val.to_s])
      end
      
      # Returns all foreign keys of the model
      def foreign_keys
        self.reflect_on_all_associations.inject([]) do |r, e|
          r << e.foreign_key
          r
        end
      end

      # Main method:
      # Used for search
      # You have params= {name: "Joh", city: "New"}
      # set has_many, belongs_to to true if you want to search for associated models
      # Search: User.search({search_params: params, has_many: true, belongs_to: false})
      def mysql_search(options={})
        params = options[:search_params]
        search_params = options[:custom_params] || nil
        act_relation = self
        attributes = (search_params||self.attributes).delete_if{|v| (self.primary_key==v[:attr].to_s || self.foreign_keys.include?(v[:attr].to_s)) }
        act_relation = belongs_to_search(act_relation, params) if options[:belongs_to] && options[:belongs_to]==true
        act_relation = has_many_search(act_relation, params) if options[:has_many] && options[:has_many]==true
        act_relation = search_conditions(attributes,params,act_relation,self.to_s)
        act_relation.select("DISTINCT #{self.table_name}.*")
      end

      # For joining belongs to relational models and searches their params
      def belongs_to_search(act_relation, params)
        self.tables_by_relation(:belongs_to).each do |c_name,values|
          act_relation = act_relation.joins("LEFT JOIN #{values[:t_name]} #{values[:t_name]} ON #{self.table_name}.#{values[:f_key]}=#{values[:t_name]}.#{c_name.constantize.pri_key}")
          new_attributes = c_name.constantize.searchable_attributes(c_name)#c_name.constantize.searchable_attributes
          act_relation = search_conditions(new_attributes,params,act_relation,c_name)
        end
        act_relation
      end

      # For joining has many relational models and searches their params
      def has_many_search(act_relation, params)
        self.tables_by_relation(:has_many).each do |c_name,values|
          act_relation = act_relation.joins("LEFT JOIN #{values[:t_name]} #{values[:t_name]} ON #{self.table_name}.#{self.pri_key}=#{values[:t_name]}.#{values[:f_key]}")
          new_attributes = c_name.constantize.searchable_attributes(c_name)#c_name.constantize.searchable_attributes
          act_relation = search_conditions(new_attributes,params,act_relation,c_name)
        end
        act_relation
      end
      
    end
    
    # includes as class methods for the Class
    def self.included(base)
      base.extend ClassMethods
    end
  end
  
  # Add the class methods to the models
  ActiveRecord::Base.send(:include, SimpleMysqlApiMethods)
end
