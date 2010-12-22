#require 'hoptoad_notifier'
HoptoadNotifier.configure do |config|
  config.api_key = SETTINGS[:hoptoad]
end