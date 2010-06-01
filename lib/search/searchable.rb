module Search
  module Searchable
    def self.included(base)
      base.class_eval do
        base.extend ClassMethods
      end
      
      super
    end

    module ClassMethods
      def search(query, page = 1, opts = {})
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
        solr_conn = RSolr.connect(:url => self.solr_url)   
        resp = solr_conn.select(:q => query, :rows  => opts[:limit], :start => opts[:offset], :qt => !opts[:qt].blank? ? opts[:qt] : "standard", :fl => '*,score')['response']

        id_name = self.idx_attrs[:_id].to_s

        return resp['docs'].map do |doc| 
          id = doc[id_name]
          if id.class == Array
            id = id[0]
          end
          find(id)
        end
      end
    end
  end
end