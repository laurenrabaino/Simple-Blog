# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

config_file_path = File.join(RAILS_ROOT, *%w(config settings.yml))
if File.exist?(config_file_path)
  config = YAML.load_file(config_file_path)
  SETTINGS = config.has_key?(RAILS_ENV) ? config[RAILS_ENV] : {}
else
  puts "WARNING: configuration file #{config_file_path} not found." 
  SETTINGS = {}
end

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  MEMCACHE_SERVERS = ['localhost']
  config.after_initialize do
    BlogCache::Cache.initialize!
  end

  config.load_paths += ["#{Rails.root}/app/concerns"]
  
  config.time_zone = 'UTC'
  DEFAULT_SECRET = "552e024ba5bbf493d1ae37aacb875359804da2f1002fa908f304c7b0746ef9ab67875b69e66361eb9484fc0308cabdced715f7e97f02395874934d401a07d3e0"
  secret = SETTINGS[:action_controller][:session][:secret] rescue DEFAULT_SECRET
  
  config.action_controller.session = { :session_key => "#{SETTINGS[:cache][:name]}_session_id", :secret => secret, :cookie_only => false}

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  config.i18n.load_path += Dir[Rails.root.join('lib', 'locales', '*.{rb,yml}')]
  config.i18n.default_locale = SETTINGS[:site][:locale]
  
end

ActiveRecord::Base.include_root_in_json = false
Tag.destroy_unused = true
ActionController::Base.asset_host = SETTINGS[:site][:host]

# some stuff for passenger
begin
   PhusionPassenger.on_event(:starting_worker_process) do |forked|
     if forked
       # We're in smart spawning mode, so...
       # Close duplicated memcached connections - they will open themselves
       CACHE.reset
     end
   end
# In case you're not running under Passenger (i.e. devmode with mongrel)
rescue NameError => error
end