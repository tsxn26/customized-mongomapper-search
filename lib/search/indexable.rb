module Search
  module Indexable
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
      base.after_save :index_to_solr
      base.before_destroy :delete_from_solr
      
      super
    end

    module ClassMethods
      # Hash where keys are the attributes and the values are the name that attributes are indexed as in Solr
      #
      # e.g. :id => "employee_id" will have the effect where the :id attribute is indexed as "employee_id" in Solr
      def idx_attr(*args)
        @idx_attrs = {}
        args.each { |x| @idx_attrs.merge!(x) }
      end

      # Hash where keys are the associations and the values are the namespace attached to the association attribute names that 
      # are indexed as Solr fields.  If a hash value is nil or a blank string then no namespace is attached to attribute names.
      #
      # e.g. Employee has a one-to-many association with Project and Project has an attribute :deadline
      #       :projects => "awesome_project" will have the effect where the :deadline attribute is indexed as "awesome_project.deadline"
      def idx_assoc(*args)
        @idx_assocs = {}
        args.each { |x| @idx_assocs.merge!(x) }
      end
      
      def idx_force_commit(commit = false)
        @idx_force_commit ||= commit
      end

      def solr_url(url = nil)
        @solr_url ||= url 
      end

      def idx_attrs
        @idx_attrs ||= {}
      end

      def idx_assocs
        @idx_assocs ||= {}
      end
    end

    module InstanceMethods
      def index_to_solr
        if self.class.solr_url   # There's no point in attempting to index if the solr url isn't specified
          fields = get_indexable_fields
          if !fields.empty?            # There's no point in indexing nothing
            solr_conn = RSolr.connect(:url => self.class.solr_url)
            solr_conn.add(fields)
            solr_conn.commit if self.class.idx_force_commit
          end
        end
      end
      
      def delete_from_solr
        if self.class.solr_url
          solr_conn = RSolr.connect(:url => self.class.solr_url)
          solr_conn.delete_by_id(self._id)
          solr_conn.commit if self.class.idx_force_commit
        end
      end

      #protected
      def get_indexable_fields
        fields = get_indexable_attributes
        fields.merge!(get_indexable_associations) if self.respond_to?(:associations) 
        fields
      end

      def get_indexable_attributes
        fields = {}
        if self.class.idx_attrs 
          self.class.idx_attrs.each_pair do |x,y|
            fields[y] = self.attributes[x]
            fields[y] = fields[y].strftime("%Y-%m-%dT%H:%M:%SZ") if fields[y].is_a?(Time)
          end
        end
        fields
      end

      # This implementation is specific to MongoMapper
      def get_indexable_associations
        fields = {}
        self.class.idx_assocs.each_pair do |name, namespace|
          v = self.associations[name]
          type = v.type
          klass = Kernel.const_get(v.class_name)
          namespace = namespace.blank? ? "" : namespace + "."

          assocs = self.send(name)
          if type == :many
            assocs.each do |x|
              if x.respond_to?("get_indexable_fields")
                x_fields = x.get_indexable_fields
                x_fields.each_pair do |field_name, field_value|
                  fields[namespace + field_name.to_s] = [] if !fields[namespace + field_name.to_s]
                  fields[namespace + field_name.to_s].push(field_value)
                end
              end
            end
          end
        end

        # Dedupe values and get rid of nils
        fields.each_pair do |x, y| 
          y.uniq! 
          y.compact!
        end
      end
    end
  end
end