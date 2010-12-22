module BlogCache
  module Cache
    
    def self.initialize!
      cache_options = { :namespace => ["#{SETTINGS[:cache][:name]}_", Rails.env].join, :show_backtraces => true }
      memcache = Memcached::Rails.new(::MEMCACHE_SERVERS, cache_options)
      Object.const_set :CACHE, memcache
      ActionController::Base.cache_store = :mem_cache_store, ::MEMCACHE_SERVERS, cache_options
      Object.const_set :RAILS_CACHE, ActionController::Base.cache_store
      
      Object.const_set :SESSION_CACHE, Memcached::Rails.new(::MEMCACHE_SERVERS, cache_options.merge({ :namespace => ["#{SETTINGS[:cache][:name]}_sessions_", Rails.env].join }))
      ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.merge!({ 'cache' => ::SESSION_CACHE })
      ActionController::Base.session_store = :mem_cache_store
      ActionController::Base.session_options[:expires] = 24.hours
    end
    
  end
end

class Memcached
  class Rails
    def get_multi(keys, raw=false)
      get_orig(keys, !raw)
    rescue NotFound
      []
    end
  end
end

CACHE_AVAILABLE                       = true
CACHE_TIMEOUT                         = SETTINGS[:cache][:timeout].to_i