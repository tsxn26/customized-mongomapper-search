# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{tsxn-mongomapper-search}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Fernando Meyer, Thomas Nguyen"]
  s.date = %q{2010-04-12}
  s.description = %q{Easily integreate mongo mapper with enterprise search like solr.  MODIFIED/CUSTOMIZED by tsxn26 to use a specified Solr URL in the model.  Original gem was written by Fernando Meyer and can be found at http://github.com/fmeyer/mongomapper-search.}
  s.email = %q{tsxn26@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "lib/search.rb", "lib/tsxn-mongomapper-search.rb"]
  s.files = ["Manifest", "README.rdoc", "Rakefile", "lib/search.rb", "lib/tsxn-mongomapper-search.rb", "tsxn-mongomapper-search.gemspec"]
  s.homepage = %q{http://github.com/tsxn26/tsxn-mongomapper-search}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Tsxn-mongomapper-search", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{tsxn-mongomapper-search}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Easily integreate mongo mapper with enterprise search like solr.  MODIFIED/CUSTOMIZED by tsxn26 to use a specified Solr URL in the model.  Original gem was written by Fernando Meyer and can be found at http://github.com/fmeyer/mongomapper-search.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<tsxn-rsolr>, [">= 0.12.1"])
      s.add_runtime_dependency(%q<mongo_mapper>, [">= 0"])
      s.add_runtime_dependency(%q<will_paginate>, [">= 2.3.11"])
    else
      s.add_dependency(%q<tsxn-rsolr>, [">= 0.12.1"])
      s.add_dependency(%q<mongo_mapper>, [">= 0"])
      s.add_dependency(%q<will_paginate>, [">= 2.3.11"])
    end
  else
    s.add_dependency(%q<tsxn-rsolr>, [">= 0.12.1"])
    s.add_dependency(%q<mongo_mapper>, [">= 0"])
    s.add_dependency(%q<will_paginate>, [">= 2.3.11"])
  end
end
