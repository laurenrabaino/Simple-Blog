module OauthConnect
  
  def get_facebook_oauth_client
    OAuth2::Client.new(SETTINGS[:facebook][:key], SETTINGS[:facebook][:secret], :site => 'https://graph.facebook.com')
  end

  def fb_access_token(code)
    begin
      get_facebook_oauth_client.web_server.get_access_token(code, :redirect_uri => SETTINGS[:facebook][:callback_url])
    rescue 
      return false
    end
  end
  
  def get_twitter_oauth_client
    TwitterOAuth::Client.new(:consumer_key => SETTINGS[:twitter][:key], :consumer_secret => SETTINGS[:twitter][:secret])
  end
  
end