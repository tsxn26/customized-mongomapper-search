# -*- encoding: utf-8 -*-

module Search::SolrDocument
  module ClassMethods
    def init_connection
      @Solr ||= RSolr.connect(:url => instance_variable_get(:@SOLR_URL))
    end
    
    def show_url
      @test ||= instance_variable_get(:@SOLR_URL)
    end
    
    def search(query, page = 1, opts = {})
      init_connection()
      WillPaginate::Collection.create(page, 20) do |pager|
        result = search_engine_query(query, opts)
        if(result.class == Array)
          result.compact!
        end
        pager.replace(result)
        pager.total_entries = result.length
      end
    end
    
    protected
    def search_engine_query(query, opts = {})
      opts.reverse_merge!(:limit => 20, :offset => 0)      
      resp = @Solr.select(:q => query, :rows  => opts[:limit], :start => opts[:offset], :qt => !opts[:qt].blank? ? opts[:qt] : "standard", :fl => '*,score')['response']
      
      if(instance_variable_defined?(:@SOLR_DOC_ID_FIELD) && !instance_variable_get(:@SOLR_DOC_ID_FIELD).blank?)
        id_name = instance_variable_get(:@SOLR_DOC_ID_FIELD)
      else  
        id_name = 'id'
      end
      
      return resp['docs'].map do |doc| 
        id = doc[id_name]
        if id.class == Array
          id = id[0]
        end
        find(id)
      end
    end    
  end

  module InstanceMethods
    def to_index
      if(self.class.instance_variable_defined?(:@SOLR_DOC_ID_FIELD) && !self.class.SOLR_DOC_ID_FIELD.blank?)
        attrs = {self.class.SOLR_DOC_ID_FIELD => self._id}
      else  
        attrs = {'id' => self._id}
      end
      
      self.keys.each_pair do |name, key|
        field_name = key.options[:solr_field_name]
        field_name ||= name
        attrs.merge!(field_name => self[name]) if key.options[:fulltext] && self[name] != nil
      end
      attrs
    end
    
    def init_connection
      @Solr ||= RSolr.connect(:url => self.class.SOLR_URL)
    end
    
    protected
    def save_on_search_engine
      init_connection
      @Solr.add(to_index)
      @Solr.commit
    end
    
    def delete_from_search_engine
      init_connection
      @Solr.delete_by_id(self._id)
      @Solr.commit
    end
  end

  def self.included(receiver)
    receiver.extend ClassMethods
    receiver.send :include, InstanceMethods
    receiver.after_save :save_on_search_engine
    receiver.before_destroy :delete_from_search_engine
  end
end
