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
        result,count = search_engine_query(query, opts)
        pager.replace(result)
        pager.total_entries = count
      end
    end
    
    protected
    def search_engine_query(query, opts = {})
      opts.reverse_merge!(:limit => 20, :offset => 0)      
      resp = @Solr.select(:q => query, :rows  => opts[:limit], :start => opts[:offset], :qt => :dismax, :fl => '*,score')['response']
      return resp['docs'].map{|doc| find(doc['id'])}, resp['numFound']      
    end    
  end

  module InstanceMethods
    def to_index
      attrs = {'id' => self._id}
      self.keys.each_pair do |name, key|
        attrs.merge!(name => self[name]) if key.options[:fulltext] && self[name] != nil
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
