ActiveRecord::Base.send :include, CacheConcerns::ModelMethods
ActionMailer::Base.send :include, CacheConcerns::ModelMethods

Delayed::Worker.backend = :active_record if SPHINX_SEARCH