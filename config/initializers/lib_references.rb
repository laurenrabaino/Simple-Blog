require 'memcached'
require 'will_paginate'
require 'url_shortener' if (OauthConnect.has_twitter? || OauthConnect.has_facebook?)
require 'twitter_oauth' if  OauthConnect.has_twitter?
require 'oauth2' if (OauthConnect.has_twitter? || OauthConnect.has_facebook?)
require "calais" if Entity.active?
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
