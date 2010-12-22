require 'memcached'
require 'will_paginate'
require 'url_shortener'
require 'twitter_oauth'
require 'oauth2'
require "calais"
require 'hoptoad_notifier'
#require 'thinking_sphinx'
#require 'thinking_sphinx/deltas/delayed_delta'

ActionView::Base.sanitized_allowed_tags.replace %w(a b em i q blockquote strike strong sub sup tt u ul ol li br p div img object embed param)
ActionView::Base.sanitized_allowed_attributes.replace %w(id type width height rel title alt href name value classid codebase allowscriptaccess src allownetworking allowfullscreen data type flashvars bgcolor) 

class String
  def sanitize(options={})
    ActionController::Base.helpers.sanitize(self, options)
  end
end
