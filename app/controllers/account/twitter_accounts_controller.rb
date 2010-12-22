class Account::TwitterAccountsController < ApplicationController
  
  resources_controller_for :twitter_account
  
  include OauthConnect
  
  before_filter :login_required
  
  def show
    unless @current_user.has_twitter_oauth?
      twitter_oauth_client = get_twitter_oauth_client
      session[:request_token] = twitter_oauth_client.request_token(:oauth_callback =>  TWITTER_CALLBACK_URL)
      @link = session[:request_token].authorize_url
    end
  end

  def callback
    twitter_oauth_client = get_twitter_oauth_client

    oauth_token = params[:oauth_token]
    oauth_verifier = params[:oauth_verifier]

		access_token = twitter_oauth_client.authorize(session[:request_token].token, session[:request_token].secret, :oauth_verifier => params[:oauth_verifier])

    if twitter_oauth_client.authorized?
      existing_twitter_account = TwitterAccount.find(:first, :conditions => ["token=? and secret=? and site_id=?", access_token.token, access_token.secret, SITE_ID])
      if !existing_twitter_account || existing_twitter_account && existing_twitter_account.user_id == @current_user.id
        unless @current_user.twitter_account
          twitter_account = TwitterAccount.create({ :user_id => @current_user.id, :token => access_token.token, :secret => access_token.secret, :site_id => SITE_ID })         
          flash[:notice] = t("account.service.linked").gsub('EXTERNAL_SITE', "Twitter").gsub('SETTINGS[:site][:name]', SETTINGS[:site][:name])
        end
      else
        flash[:notice] = t("account.service.already_linked").gsub('EXTERNAL_SITE', 'Twitter').gsub('SETTINGS[:site][:name]', SETTINGS[:site][:name])
      end
    else
      flash[:notice] = t("account.service.oops").gsub('EXTERNAL_SITE', "Twitter").gsub('SETTINGS[:site][:name]', SETTINGS[:site][:name])
    end
    redirect_to account_twitter_account_path
  end

end