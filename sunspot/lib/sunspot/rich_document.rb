module Sunspot
  class RichDocument < RSolr::Message::Document
    include Enumerable

    def contains_attachment?
      @fields.each do |field|
        if field.name.to_s.include?("_attachment")
          return true
        end
      end
      return false
    end

    def add(connection)
      params = {
        :wt => :ruby,
        'idx.attr' => false, # don't index any attributes, unless explicitly mapped
        'map.title' => 'title_text',
      }

      data = nil

      @fields.each do |f|
        puts f.name.to_s + " " + f.value.to_s
        
        if f.name.to_s.include?("_attachment")
          data = open(f.value).read
          params['def.fl'] = f.name, # all text extracted goes to text_t (since it is a stored field, for highlighting)
          params['fmap.content'] = f.name
        else
          param_name = "literal.#{f.name.to_s}"
          params[param_name] = [] unless params.has_key?(param_name)
          params[param_name] << f.value          
        end

#          if f.boost
#            params["boost.#{f.name.to_s}"] = f.boost
#          end
      end

      solr_message = params
      pp connection.send('update/extract', solr_message, data)
    end
  end
end
