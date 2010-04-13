require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('tsxn-mongomapper-search', '0.1.0') do |p|
  p.description    = "Easily integreate mongo mapper with enterprise search like solr.  MODIFIED/CUSTOMIZED by tsxn26 to use a specified Solr URL in the model.  Original gem was written by Fernando Meyer and can be found at http://github.com/fmeyer/mongomapper-search."
  p.url            = "http://github.com/tsxn26/tsxn-mongomapper-search"
  p.author         = ["Fernando Meyer", "Thomas Nguyen"]
  p.email          = "tsxn26@gmail.com"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.runtime_dependencies = ["tsxn-rsolr >=0.12.1", "mongo_mapper", "will_paginate >=2.3.11"]
  p.development_dependencies = []
end
